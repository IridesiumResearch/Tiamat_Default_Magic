// SPDX-FileCopyrightText: Iridesium
// SPDX-License-Identifier: GPL-3.0-only
//
// The mod, run for real: the engine's script VM with a fake server around it
// (rig.rs), the real sibling mods loaded beside it, and a probe above it
// that asks them what they see (fixtures/probe.lua).

// The rig carries fakes not every test reads.
#[allow(dead_code)]
mod rig;

use rig::{MOD, PLAYER, Rig, Setup};

fn main() {
    loads();
    loads_without_the_optional_mods();
    the_bench();
    flames();
    the_book();
    creative();
    the_tree();
    the_door();
    determinism();
    println!("magic native check: all passed");
}

fn op(r: &Rig) {
    r.huds.operators.lock().unwrap().push(PLAYER);
}

/// A player who has lit a first fire and has insight to spend.
fn ready(r: &mut Rig, insight: i32) {
    r.join(PLAYER);
    r.tick(1);
    op(r);
    assert_eq!(r.ask("progress grant shared.firecraft"), "Learned: Firecraft", "an operator's grant");
    assert_eq!(r.ask(&format!("t award {insight}")), insight.to_string());
}

fn learn(r: &mut Rig, node: &str) {
    assert_eq!(r.ask(&format!("t learn {node}")), "true", "learning {node}");
}

/// Everything registers into the real siblings, and nothing is refused.
fn loads() {
    let mut r = Rig::new(Setup::default());
    r.join(PLAYER);
    r.tick(1);
    let mut nodes: Vec<String> = r.ask("t nodes").split(' ').map(str::to_owned).collect();
    nodes.sort();
    assert_eq!(
        nodes,
        ["shared.apothecary/1/10", "shared.foxfire/2/20", "shared.herb_lore/1/10", "shared.mutus_liber/1/5", "shared.stillroom/2/25"],
        "Progress validated all five Bench nodes"
    );
    assert_eq!(r.ask("t magic"), "1", "the export is version 1");
    assert_eq!(r.ask("magic"), "The Apothecary's Bench: 0 of 5 learned.");
    // Every Bench recipe is in Craft, and gated on its node.
    for recipe in ["mutus_liber", "mortar", "grind_chamomile", "flame_powder_blue", "poultice", "hermetic_lamp"] {
        let answer = r.ask(&format!("t can {MOD}:{recipe}"));
        assert!(answer.starts_with("nil") && !answer.contains("no such"), "{recipe}: {answer}");
    }
    println!("loads: ok");
}

/// Without the interface and the weather, which are optional, it still loads
/// and the book still opens, as a plain dialog.
fn loads_without_the_optional_mods() {
    let mut r = Rig::new(Setup { ui: false, weather: false, ..Setup::default() });
    ready(&mut r, 10);
    learn(&mut r, "shared.mutus_liber");
    r.give(PLAYER, "mutus_liber", 27);
    r.hold(PLAYER, "mutus_liber");
    assert!(r.use_at_nothing(PLAYER), "the book is read at nothing");
    let (form, tree) = r.last_dialog().expect("the book");
    assert_eq!(form, format!("{MOD}:liber"));
    assert!(tree.contains("The Mute Book"), "{tree}");
    println!("loads without the optional mods: ok");
}

/// The child's half hour: the book, the mortar, a simple, a tea's
/// ingredients, a lamp. Every node costs what the brief says, and nothing a
/// child makes is lost.
fn the_bench() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 70);

    // The book, by hand.
    assert!(r.ask(&format!("t can {MOD}:mutus_liber")).starts_with("nil"), "gated before its node");
    learn(&mut r, "shared.mutus_liber");
    assert_eq!(r.ask("t insight"), "65");
    r.give(PLAYER, "tiamat_default_craft:leather", 27);
    r.give(PLAYER, "tiamat_default_craft:bark_strip", 54);
    r.give(PLAYER, "tiamat_default_craft:charcoal", 27);
    assert_eq!(r.ask(&format!("t make {MOD}:mutus_liber")), "made");
    assert_eq!(r.units(PLAYER, "mutus_liber"), 27);
    assert_eq!(r.units(PLAYER, "tiamat_default_craft:bark_strip"), 0);

    // The mortar, and a simple ground in it; the mortar is not worn.
    learn(&mut r, "shared.apothecary");
    r.give(PLAYER, "tiamat_default_craft:fired_clay", 54);
    r.give(PLAYER, "tiamat_default_craft:stick", 27);
    assert_eq!(r.ask(&format!("t make {MOD}:mortar")), "made");
    r.give(PLAYER, "tiamat_default_world:roman_chamomile", 3);
    assert_eq!(r.ask(&format!("t make {MOD}:grind_chamomile")), "made");
    assert_eq!(r.units(PLAYER, "simple_chamomile"), 27);
    assert_eq!(r.units(PLAYER, "mortar"), 27, "the mortar is kept");
    assert_eq!(r.units(PLAYER, "tiamat_default_world:roman_chamomile"), 0);

    // A poultice, by hand.
    learn(&mut r, "shared.herb_lore");
    r.give(PLAYER, "tiamat_default_world:ladys_mantle", 3);
    assert_eq!(r.ask(&format!("t make {MOD}:grind_mantle")), "made");
    r.give(PLAYER, "tiamat_default_craft:bark_strip", 27);
    assert_eq!(r.ask(&format!("t make {MOD}:poultice")), "made");
    assert_eq!(r.units(PLAYER, "poultice"), 27);

    // The lamp: a toybox discovery the first time.
    learn(&mut r, "shared.foxfire");
    let before: i32 = r.ask("t insight").parse().unwrap();
    r.give(PLAYER, "tiamat_default_craft:glass", 27);
    r.give(PLAYER, "tiamat_default_world:glow_cap", 9);
    assert_eq!(r.ask(&format!("t make {MOD}:hermetic_lamp")), "made");
    assert_eq!(r.units(PLAYER, "hermetic_lamp"), 27);
    let after: i32 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - before, 5, "a lamp that never goes out");

    learn(&mut r, "shared.stillroom");
    assert_eq!(r.ask("magic"), "The Apothecary's Bench: 5 of 5 learned.");
    assert_eq!(r.ask("t insight"), "5", "the Bench's nodes cost 70 insight, and the lamp paid 5 back");
    println!("the bench: ok");
}

/// A powder thrown at a lit kiln, put on a campfire, and used anywhere else.
fn flames() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 15);
    learn(&mut r, "shared.mutus_liber");
    learn(&mut r, "shared.apothecary");
    r.give(PLAYER, "mortar", 27);

    // Blue, thrown at a kiln that burns: taken, seen and paid for.
    r.give(PLAYER, "tiamat_default_world:sulfur", 9);
    assert_eq!(r.ask(&format!("t make {MOD}:flame_powder_blue")), "made");
    r.put_block(10, 64, 10, "tiamat_default_craft:kiln_lit");
    r.hold(PLAYER, "flame_powder_blue");
    r.heard(PLAYER);
    r.bursts();
    assert!(r.use_at(PLAYER, 10, 64, 10), "the kiln takes the powder");
    assert_eq!(r.units(PLAYER, "flame_powder_blue"), 0);
    let heard = r.heard(PLAYER);
    assert!(heard.iter().any(|l| l == "The fire burns blue!"), "{heard:?}");
    let bursts = r.bursts();
    assert_eq!(bursts.len(), 1, "one flare: {bursts:?}");
    assert!(bursts[0].contains("pos: [10.5, 64.9, 10.5]"), "over the kiln: {}", bursts[0]);
    assert_eq!(r.ask("t insight"), "3", "a coloured flame, the first time");

    // Used at anything that is not a fire: nothing happens, nothing is lost.
    r.give(PLAYER, "tiamat_default_world:sulfur", 9);
    assert_eq!(r.ask(&format!("t make {MOD}:flame_powder_blue")), "made");
    r.put_block(12, 64, 12, "tiamat_default_world:stone");
    assert!(!r.use_at(PLAYER, 12, 64, 12), "stone is not a fire");
    assert_eq!(r.units(PLAYER, "flame_powder_blue"), 27, "the powder stays in the hand");

    // The same colour again flares, and pays nothing more.
    assert!(r.use_at(PLAYER, 10, 64, 10));
    assert_eq!(r.ask("t insight"), "3");

    // Green, put on a campfire: Craft burns it, and the flare is at the fire
    // the player is looking at.
    r.give(PLAYER, "tiamat_default_craft:copper_ingot", 27);
    assert_eq!(r.ask(&format!("t make {MOD}:flame_powder_green")), "made");
    assert_eq!(r.units(PLAYER, "flame_powder_green"), 81, "an ingot files into three");
    r.put_block(5, 64, 5, "tiamat_default_craft:campfire_lit");
    r.aim(5, 64, 5);
    r.bursts();
    r.heard(PLAYER);
    r.say("t burn green");
    let heard = r.heard(PLAYER);
    assert_eq!(heard.last().map(String::as_str), Some("burnt"), "{heard:?}");
    assert!(heard.iter().any(|l| l == "The fire burns green!"), "{heard:?}");
    let bursts = r.bursts();
    assert_eq!(bursts.len(), 1, "{bursts:?}");
    assert!(bursts[0].contains("pos: [5.5, 64.9, 5.5]"), "over the campfire: {}", bursts[0]);
    assert_eq!(r.ask("t insight"), "6");
    println!("flames: ok");
}

/// The Mute Book: a page for each node held or next, with what it makes.
fn the_book() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 5);
    learn(&mut r, "shared.mutus_liber");
    r.give(PLAYER, "mutus_liber", 27);

    assert_eq!(r.ask("magic book"), "", "opened, and nothing said");
    let (form, tree) = r.last_dialog().expect("the book");
    assert_eq!(form, format!("{MOD}:liber"));
    assert!(tree.contains("The Mute Book") && tree.contains("The Apothecary's Mortar"), "{tree}");
    assert!(tree.contains("Learn it at the research table for 10 insight."), "the next node, unlearned: {tree}");
    assert!(!tree.contains("Herb Lore"), "never the whole tree at once");
    assert!(tree.contains("leather + 2 bark strip + charcoal  ->  The Mute Book, by hand"), "{tree}");

    // Using the book at a block opens it too.
    r.put_block(3, 64, 3, "tiamat_default_world:stone");
    r.hold(PLAYER, "mutus_liber");
    r.dialogs.shown.lock().unwrap().clear();
    assert!(r.use_at(PLAYER, 3, 64, 3));
    assert!(r.last_dialog().is_some());

    // Without a book, the word says how to make one.
    r.inventory.clear(PLAYER);
    assert!(r.ask("magic book").starts_with("You have no Mute Book."));
    println!("the book: ok");
}

/// In a Creative world every shared node is held, so the Bench is open.
fn creative() {
    let mut r = Rig::new(Setup { mode: Some("Creative".into()), ..Setup::default() });
    r.join(PLAYER);
    r.tick(1);
    assert_eq!(r.ask("magic"), "The Apothecary's Bench: 5 of 5 learned.");
    println!("creative: ok");
}

/// All 97 path nodes are in Progress, none disabled, and every one is
/// beyond the Fork for a player without a path.
fn the_tree() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 5000);
    assert_eq!(r.ask("t count"), "97", "Progress validated the whole tree");
    let answer = r.ask("t learn magic.athanor");
    assert!(answer.starts_with("nil") && answer.contains("lies beyond the Fork"), "{answer}");
    let answer = r.ask("t learn magic.hermes_trismegistus");
    assert!(answer.starts_with("nil"), "{answer}");
    assert_eq!(r.ask("t insight"), "5000", "nothing was spent");
    println!("the tree: ok");
}

/// The Emerald Tablet: its recipe waits for the Keystone; choosing it binds
/// the player, gives the Oath free and the Mute Book once, and opens the
/// tree, whose effects Progress then sums.
fn the_door() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 500);
    let answer = r.ask("t can tiamat_default_progress:door_magic");
    assert!(answer.starts_with("nil") && !answer.contains("no such"), "the door's recipe, gated: {answer}");

    // Without the Keystone the Tablet is shut.
    r.put_block(20, 64, 20, "emerald_tablet");
    assert!(r.use_at(PLAYER, 20, 64, 20));
    assert_eq!(r.said(), "The door is shut to you. Learn the Keystone first.");

    // With it, the Tablet asks, and Yes binds.
    assert_eq!(r.ask("progress grant shared.keystone"), "Learned: The Keystone");
    assert!(r.use_at(PLAYER, 20, 64, 20));
    let (form, tree) = r.last_dialog().expect("the Fork's question");
    assert_eq!(form, "tiamat_default_progress:fork");
    assert!(tree.contains("As above, so below."), "{tree}");
    r.heard(PLAYER);
    r.press(PLAYER, "tiamat_default_progress", "fork", "yes");
    let heard = r.heard(PLAYER);
    assert!(heard.iter().any(|l| l == "You have taken the Oath. Seek the Athanor."), "{heard:?}");
    assert_eq!(r.ask("t path"), "magic");
    assert_eq!(r.ask("t has magic.hermetic_oath"), "true", "the Oath, free");
    assert_eq!(r.ask("t insight"), "500", "and it cost nothing");
    assert_eq!(r.units(PLAYER, "mutus_liber"), 27, "the Mute Book, once");

    // The tree is open now, and its effects are summed.
    assert_eq!(r.ask("t learn magic.seven_metals"), "true");
    assert_eq!(r.ask("t learn magic.sigils"), "true");
    assert_eq!(r.ask("t effects magic."), "magic.sigil_percent=15");
    assert_eq!(r.ask("t insight"), "320");

    // Using the Tablet again says so, and gives no second book.
    assert!(r.use_at(PLAYER, 20, 64, 20));
    assert_eq!(r.said(), "You are already of The Hermetic Art.");
    assert_eq!(r.units(PLAYER, "mutus_liber"), 27);
    println!("the door: ok");
}

/// The same play twice leaves the same storage.
fn determinism() {
    let play = || {
        let mut r = Rig::new(Setup::default());
        ready(&mut r, 15);
        learn(&mut r, "shared.mutus_liber");
        learn(&mut r, "shared.apothecary");
        r.give(PLAYER, "mortar", 27);
        r.give(PLAYER, "tiamat_default_world:sulfur", 9);
        r.ask(&format!("t make {MOD}:flame_powder_blue"));
        r.put_block(10, 64, 10, "tiamat_default_craft:kiln_lit");
        r.hold(PLAYER, "flame_powder_blue");
        r.use_at(PLAYER, 10, 64, 10);
        r.tick(20);
        // Every mod's storage, not only this one's: the Bench keeps nothing of
        // its own yet, and what it causes lands in Progress and Craft.
        r.storage.0.lock().unwrap().iter().map(|((m, k), v)| format!("{m}/{k}={v:?}")).collect::<Vec<_>>().join("\n")
    };
    assert_eq!(play(), play());
    println!("determinism: ok");
}
