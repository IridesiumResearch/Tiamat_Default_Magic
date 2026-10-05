// SPDX-FileCopyrightText: Iridesium
// SPDX-License-Identifier: GPL-3.0-only
//
// The mod, run for real: the engine's script VM with a fake server around it
// (rig.rs), the real sibling mods loaded beside it, and a probe above it
// that asks them what they see (fixtures/probe.lua).

// The rig carries fakes not every test reads.
#[allow(dead_code)]
mod rig;

use rig::{MOD, OTHER, PLAYER, Rig, Setup};

fn main() {
    loads();
    loads_without_the_optional_mods();
    the_bench();
    flames();
    the_book();
    creative();
    the_tree();
    the_door();
    the_blocks();
    the_athanor();
    spagyrics();
    glyphs();
    sigils();
    swiftness();
    weathering();
    salamander();
    nigredo();
    spills_and_theriac();
    tree_of_diana();
    talismans();
    the_seal();
    ouroboros();
    undine();
    gnome_and_sylph();
    quintessence();
    the_white_stone();
    caduceus();
    the_gifts();
    the_red_stone();
    alkahest_and_panacea();
    phoenix_and_wedding();
    homunculus_and_basilisk();
    microcosm_and_gates();
    rose_garden();
    world_projection_and_the_assay();
    lapis_infinitus();
    quintessences_of_the_four();
    woven_worlds();
    thrice_greatest();
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
    // Not looking at it: Craft says which fire burnt it.
    r.put_block(5, 64, 5, "tiamat_default_craft:campfire_lit");
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

    // Its key opens it too.
    r.dialogs.shown.lock().unwrap().clear();
    r.action(PLAYER, &format!("{MOD}:mutus_liber"));
    assert_eq!(r.last_dialog().map(|d| d.0), Some(format!("{MOD}:liber")), "on J");

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

/// Every shipped path node — tiers 3 to `built_tier`, 85 while tier 6 is
/// the last built — is in Progress, none disabled, and every one is
/// beyond the Fork for a player without a path.
fn the_tree() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 5000);
    assert_eq!(r.ask("t count"), "97", "Progress validated what ships: tiers 3 to 7");
    let answer = r.ask("t learn magic.athanor");
    assert!(answer.starts_with("nil") && answer.contains("lies beyond the Fork"), "{answer}");
    let answer = r.ask("t learn magic.hermes_trismegistus");
    assert!(answer.starts_with("nil"), "{answer}");
    assert_eq!(r.ask("t insight"), "5000", "nothing was spent");
    // Grouped by branch (Progress's P-M1); each node's reveal is left to the
    // path's, `near`, which the Research tab applies.
    assert_eq!(r.ask("t node magic.rubedo"), "OPUS/nil");
    assert_eq!(r.ask("t node magic.gate_calcination"), "GATE/nil");
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

/// The five blocks' looks (Sub-Node Contract §7.5, §8.6): the athanor, lit
/// and cold, and the Tablet drawn as models and so whole, each with the shape
/// the world knows; the lamp a whole glass cube; the Tree of Diana neither,
/// since it grows a cell at a time and is paid by the share it fills.
fn the_blocks() {
    use tiamat_core::script::ScriptVm;
    let r = Rig::new(Setup::default());
    let rules = r.vm.registered_block_rules();
    let of = |id: &str| {
        let id = format!("{MOD}:{id}");
        rules.iter().find(|b| b.block == id).unwrap_or_else(|| panic!("{id} registered"))
    };
    // A layer string to its 9 bits, in the engine's cell order (x + 3y + 9z).
    let mask = |layers: [&str; 3]| -> u32 {
        let mut m = 0;
        for (y, layer) in layers.iter().enumerate() {
            for (i, c) in layer.chars().filter(|c| !c.is_whitespace()).enumerate() {
                if c == '#' {
                    m |= 1 << ((i % 3) + 3 * y + 9 * (i / 3));
                }
            }
        }
        m
    };
    let tower = mask(["### ### ###", "### ### ###", ".#. ### .#."]);
    for (id, model, shape) in [
        ("athanor", "athanor", tower),
        ("athanor_lit", "athanor_lit", tower),
        ("emerald_tablet", "emerald_tablet", mask(["### ### ###", "... ### ...", "... ### ..."])),
    ] {
        let b = of(id);
        assert!(b.whole, "{id} is whole");
        assert_eq!(b.model.as_deref(), Some(format!("{MOD}:{model}").as_str()), "{id}'s model");
        assert_eq!(b.shape, shape, "{id}'s shape");
    }
    let lamp = of("hermetic_lamp");
    assert!(lamp.whole && lamp.model.is_none() && lamp.transparent, "the lamp: a whole glass cube");
    assert_eq!(lamp.shape, 0x7FF_FFFF);
    let tree = of("arbor_dianae");
    assert!(!tree.whole && tree.model.is_none(), "the Tree of Diana grows by the cell");
    println!("the blocks: ok");
}

/// A player on the magic path, holding `nodes` (granted by an operator).
fn adept(r: &mut Rig, nodes: &[&str]) {
    ready(r, 0);
    assert_eq!(r.ask("progress grant shared.keystone"), "Learned: The Keystone");
    r.put_block(20, 64, 20, "emerald_tablet");
    assert!(r.use_at(PLAYER, 20, 64, 20));
    r.press(PLAYER, "tiamat_default_progress", "fork", "yes");
    assert_eq!(r.ask("t path"), "magic");
    for node in nodes {
        assert!(r.ask(&format!("progress grant {node}")).starts_with("Learned"), "granting {node}");
    }
}

/// An athanor at `(x, y, z)`: placed, its container made by Craft when it
/// is first used, and filled slot by slot (`(slot, id, units)`).
fn athanor(r: &mut Rig, (x, y, z): (i32, i32, i32), slots: &[(usize, &str, u32)]) -> String {
    r.put_block(x, y, z, "athanor");
    r.inventory.held.lock().unwrap().remove(&PLAYER);
    assert!(r.use_at(PLAYER, x, y, z), "Craft opens the athanor");
    let name = format!("tiamat_default_craft:{MOD}:athanor:{x},{y},{z}");
    assert!(r.boxes.exists(&name), "the athanor's container");
    r.boxes.holders.lock().unwrap().clear();
    for (slot, id, units) in slots {
        r.boxes.set(&name, *slot, Some(tiamat_core::inventory::Stack::new(r.material(id), *units).unwrap()));
    }
    name
}

/// Lights the athanor at `(x, y, z)` with a fire striker.
fn light(r: &mut Rig, (x, y, z): (i32, i32, i32)) {
    r.give(PLAYER, "tiamat_default_craft:fire_striker", 27);
    r.hold(PLAYER, "tiamat_default_craft:fire_striker");
    assert!(r.use_at(PLAYER, x, y, z), "struck");
    r.inventory.held.lock().unwrap().remove(&PLAYER);
}

fn slot(r: &Rig, name: &str, n: usize) -> Option<(String, u32)> {
    r.boxes.get(name, n).map(|s| {
        let id = r.materials.iter().find(|(_, m)| **m == s.material).map(|(k, _)| k.clone()).unwrap_or_default();
        (id, s.units)
    })
}

/// The athanor burns on its own: the 4th degree with bellows calcines a
/// metal and opens Gate I; Maria's bath ferments fruit in a philosophical
/// day; nothing runs without the right vessel.
fn the_athanor() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.bain_marie",
        "magic.vinegar_and_wine"]);
    let insight: i32 = r.ask("t insight").parse().unwrap();

    // Gate I: copper at naked fire. Bellows in a vessel slot make heat 4.
    let at = (30, 64, 30);
    let name = athanor(&mut r, at, &[
        (1, "tiamat_default_world:coal", 27 * 4),
        (2, "tiamat_default_craft:copper_ingot", 27),
        (5, "tiamat_default_craft:bellows", 27),
    ]);
    light(&mut r, at);
    r.tick(700);
    assert_eq!(slot(&r, &name, 7), Some((format!("{MOD}:aes_ustum"), 27)), "copper, calcined");
    assert_eq!(slot(&r, &name, 2), None, "the copper is used");
    let after: i32 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - insight, 25, "Gate I: Calcination");

    // Without the bellows the same copper sits there: 2nd-degree heat is not naked fire.
    let at2 = (34, 64, 30);
    let name2 = athanor(&mut r, at2, &[
        (1, "tiamat_default_world:coal", 27 * 4),
        (2, "tiamat_default_craft:copper_ingot", 27),
    ]);
    light(&mut r, at2);
    r.tick(700);
    assert_eq!(slot(&r, &name2, 7), None, "no naked fire, no calx");

    // Wine: berries and water in Maria's bath, one philosophical day.
    let at3 = (38, 64, 30);
    let name3 = athanor(&mut r, at3, &[
        (1, "tiamat_default_world:coal", 27 * 4),
        (2, "tiamat_default_life:berries", 27 * 3),
        (3, "tiamat_default_life:water_bucket", 27),
        (5, "bain_marie", 27),
    ]);
    light(&mut r, at3);
    r.tick(1700);
    assert_eq!(slot(&r, &name3, 7), None, "not before a day");
    r.tick(200);
    let out: Vec<_> = (7..=9).filter_map(|n| slot(&r, &name3, n)).collect();
    assert!(out.contains(&(format!("{MOD}:vinum"), 27)), "{out:?}");
    assert!(out.contains(&("tiamat_default_life:bucket".to_owned(), 27)), "the bucket back: {out:?}");
    println!("the athanor: ok");
}

/// A herb and a spirit make its planet's tincture, a first species pays,
/// the tincture in a phial is an elixir, and night-sight glows on the
/// drinker until it runs out.
fn spagyrics() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.bain_marie", "magic.glassblowing", "magic.vinegar_and_wine",
        "magic.aqua_vitae", "magic.spagyric_tincture", "magic.simple_elixirs"]);
    let insight: i32 = r.ask("t insight").parse().unwrap();

    let at = (40, 64, 40);
    let name = athanor(&mut r, at, &[
        (1, "tiamat_default_world:coal", 27 * 2),
        (2, "tiamat_default_world:roman_chamomile", 9),
        (3, "spirit_of_wine", 27),
        (5, "bain_marie", 27),
    ]);
    light(&mut r, at);
    r.tick(1900);
    assert_eq!(slot(&r, &name, 7), Some((format!("{MOD}:tincture_sol"), 27)), "chamomile is Sol's");
    let after: i32 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - insight, 5, "a first tincture of roman chamomile");

    // The elixir, by hand; Luna's for night-sight.
    r.give(PLAYER, "tincture_luna", 27);
    r.give(PLAYER, "phial", 27);
    assert_eq!(r.ask(&format!("t make {MOD}:elixir_night_sight")), "made");
    assert_eq!(r.units(PLAYER, "elixir_night_sight"), 27);
    assert_eq!(r.units(PLAYER, "phial"), 0, "the phial holds it");

    // Drunk through Life, it starts this mod's own effect: a glow of motes,
    // for the drinker alone, every 40 ticks, until it runs out.
    r.hold(PLAYER, "elixir_night_sight");
    assert!(r.use_at_nothing(PLAYER), "Life drinks it");
    assert_eq!(r.units(PLAYER, "elixir_night_sight"), 0, "drunk");
    r.bursts();
    r.tick(80);
    let glow: Vec<_> = r.bursts().into_iter().filter(|b| b.contains("player: Some")).collect();
    assert!(!glow.is_empty(), "the drinker glows");
    assert!(r.stored(&format!("fx:{}:night_sight", rig::hex(PLAYER))).is_some(), "a timer, in storage");
    r.tick(2400);
    r.bursts();
    r.tick(80);
    assert!(r.bursts().iter().all(|b| !b.contains("player: Some")), "and it runs out");
    assert!(r.stored(&format!("fx:{}:night_sight", rig::hex(PLAYER))).is_none(), "the timer is gone");
    println!("spagyrics: ok");
}

/// Venus, the canonical mask the brief draws.
const VENUS: u32 = 100433791;

/// Every glyph is Craft's in each of its orientations.
fn glyphs() {
    let mut r = Rig::new(Setup::default());
    r.join(PLAYER);
    r.tick(1);
    assert_eq!(r.ask(&format!("t glyph {VENUS}")), format!("{MOD}:venus"));
    // Venus turned on its side (y and z swapped) and mirrored in x: still Venus.
    let mut turned = 0u32;
    for i in 0..27 {
        if VENUS >> i & 1 == 1 {
            let (x, y, z) = (i % 3, (i / 3) % 3, i / 9);
            turned |= 1 << ((2 - x) + 3 * z + 9 * y);
        }
    }
    assert_ne!(turned, VENUS);
    assert_eq!(r.ask(&format!("t glyph {turned}")), format!("{MOD}:venus"), "any orientation");
    assert_eq!(r.ask("t glyph 7"), "nil", "a sliver is nothing");
    println!("glyphs: ok");
}

/// A Venus sigil against a burning athanor that is calcining copper speeds
/// it by its setter's knowledge; the same athanor with no sigil is slower.
fn sigils() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.seven_metals",
        "magic.sigils"]);
    let fuel = ("tiamat_default_world:coal", 27 * 4);
    let with = (50, 64, 50);
    let without = (60, 64, 60);
    let a = athanor(&mut r, with, &[(1, fuel.0, fuel.1), (2, "tiamat_default_craft:copper_ingot", 27),
        (5, "tiamat_default_craft:bellows", 27)]);
    let b = athanor(&mut r, without, &[(1, fuel.0, fuel.1), (2, "tiamat_default_craft:copper_ingot", 27),
        (5, "tiamat_default_craft:bellows", 27)]);
    // The sigil: carved from copper ore, set on the athanor's east side.
    assert!(r.place_event(PLAYER, (51, 64, 50), "tiamat_default_world:copper_ore", VENUS), "placing is allowed");
    r.put_carved(51, 64, 50, "tiamat_default_world:copper_ore", VENUS);
    light(&mut r, with);
    light(&mut r, without);
    r.tick(520);
    assert_eq!(slot(&r, &a, 7), Some((format!("{MOD}:aes_ustum"), 27)), "sped by the sign");
    assert_eq!(slot(&r, &b, 7), None, "not yet, without one");
    r.tick(120);
    assert_eq!(slot(&r, &b, 7), Some((format!("{MOD}:aes_ustum"), 27)), "in its own time");
    // Dug, a sign is forgotten. (Ore wants a pick, and Craft refuses a hand
    // before this mod hears the dig, so the sign dug here is carved of dirt.)
    assert!(r.place_event(PLAYER, (70, 64, 70), "tiamat_default_world:dirt", VENUS));
    r.put_carved(70, 64, 70, "tiamat_default_world:dirt", VENUS);
    assert!(r.stored("carved:70,64,70").is_some(), "its setter, remembered");
    r.dig_event(PLAYER, (70, 64, 70));
    assert!(r.stored("carved:70,64,70").is_none(), "and forgotten");
    println!("sigils: ok");
}

/// Mercury's elixir is quick feet through Life's composed abilities, and
/// the speed is taken off again when it runs out.
fn swiftness() {
    rig::ABILITIES.lock().unwrap().clear();
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 0);
    r.give(PLAYER, "elixir_swiftness", 27);
    r.hold(PLAYER, "elixir_swiftness");
    assert!(r.use_at_nothing(PLAYER), "Life drinks it");
    r.tick(20);
    let fast = |a: &Option<tiamat_core::phys::Abilities>| a.as_ref().is_some_and(|a| format!("{a:?}").contains("1.3"));
    assert!(rig::ABILITIES.lock().unwrap().iter().any(|(p, a)| *p == PLAYER && fast(a)), "sped up: {:?}",
        rig::ABILITIES.lock().unwrap().last());
    r.tick(1300);
    let last = rig::ABILITIES.lock().unwrap().iter().rev().find(|(p, _)| *p == PLAYER).cloned();
    assert!(last.is_some_and(|(_, a)| !fast(&a)), "and slowed again");
    println!("swiftness: ok");
}

/// Pyrite under open sky in the rain weathers on its random tick, and dug,
/// it is green vitriol. Dry pyrite is pyrite. (A Creative world, so a hand
/// may dig what wants a pick: Craft refuses before this mod hears a dig.)
fn weathering() {
    let mut r = Rig::new(Setup { mode: Some("Creative".into()), ..Setup::default() });
    ready(&mut r, 0);
    let wet = (101, 64, 100);
    let dry = (103, 64, 100);
    r.put_block(wet.0, wet.1, wet.2, "tiamat_default_world:pyrite");
    r.put_block(dry.0, dry.1, dry.2, "tiamat_default_world:pyrite");
    r.random_tick(dry);
    assert_eq!(r.dig_event(PLAYER, dry), None, "dry pyrite is pyrite");
    let answer = r.ask("/weather set rain 30");
    assert!(answer.starts_with("rain over square"), "{answer}");
    r.tick(1200);
    r.random_tick(wet);
    assert!(r.stored(&format!("weathered:{},{},{}", wet.0, wet.1, wet.2)).is_some(), "weathered in the rain");
    let drops = r.dig_event(PLAYER, wet).expect("weathered pyrite says what it drops");
    assert_eq!(drops, vec![(format!("{MOD}:green_vitriol"), 27)]);
    assert!(r.stored(&format!("weathered:{},{},{}", wet.0, wet.1, wet.2)).is_none(), "and forgets it");
    println!("weathering: ok");
}

/// The salamander: the model parses as the engine parses it; an athanor
/// burning a philosophical day draws one for the adept beside it; sulfur
/// binds it, with its ember; it leaves with its master and comes back.
fn salamander() {
    let bytes = std::fs::read(concat!(env!("CARGO_MANIFEST_DIR"), "/../../mods/tiamat_default_magic/models/salamander.glb"))
        .expect("the model file");
    tiamat_core::model::load(&bytes, &tiamat_core::model::Limits::default()).expect("the engine reads the model");

    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.salamander"]);
    let model = format!("{MOD}:salamander");
    let at = (105, 64, 100);
    athanor(&mut r, at, &[(1, "tiamat_default_world:coal", 27 * 3)]);
    light(&mut r, at);
    r.heard(PLAYER);
    r.tick(1300);
    assert!(r.with_model(&model).is_empty(), "not before a day's burning");
    r.tick(1300);
    let wild = r.with_model(&model);
    assert_eq!(wild.len(), 1, "one comes");
    assert!(r.heard(PLAYER).iter().any(|l| l == "Something stirs in the athanor's fire."));
    r.tick(1300);
    assert_eq!(r.with_model(&model).len(), 1, "and only one, for one fire");

    // Empty-handed, it wants sulfur; with a handful, it is bound.
    let (handled, said) = r.use_entity(PLAYER, wild[0]);
    assert!(handled);
    assert_eq!(said.as_deref(), Some("It flickers, hungry. It wants sulfur."));
    let insight: i32 = r.ask("t insight").parse().unwrap();
    r.give(PLAYER, "tiamat_default_world:sulfur", 9);
    r.hold(PLAYER, "tiamat_default_world:sulfur");
    let (handled, _) = r.use_entity(PLAYER, wild[0]);
    assert!(handled, "bound");
    assert_eq!(r.units(PLAYER, "tiamat_default_world:sulfur"), 0, "it ate the sulfur");
    assert_eq!(r.units(PLAYER, "salamander_ember"), 0, "its ember is the Forge's gift");
    assert!(r.ask("progress grant magic.salamander_forge").starts_with("Learned"));
    assert_eq!(r.units(PLAYER, "salamander_ember"), 27, "the Forge learned: its ember");
    let after: i32 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - insight, 30, "a salamander, bound");
    assert_eq!(r.stored(&format!("familiar:{}:salamander", rig::hex(PLAYER))).as_deref(), Some("Flag(true)"));

    // It leaves with its master and comes back with them.
    r.leave(PLAYER);
    assert!(r.with_model(&model).is_empty(), "gone with them");
    r.join(PLAYER);
    r.tick(1);
    assert_eq!(r.with_model(&model).len(), 1, "back with them");
    println!("salamander: ok");
}

/// Tier 4's spine: quicksilver from the world's cinnabar; the nigredo, three
/// philosophical days in the Egg, opening Gate V; the Peacock's Tail,
/// shimmering while it works and paying the first time.
fn nigredo() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.bain_marie", "magic.retort",
        "magic.quicksilver", "magic.philosophers_egg", "magic.gate_putrefaction", "magic.cauda_pavonis"]);

    // Cinnabar in the retort, in the sand bath, on coal.
    let q = (80, 64, 80);
    let qn = athanor(&mut r, q, &[(1, "tiamat_default_world:coal", 27 * 2), (2, "tiamat_default_world:cinnabar", 27),
        (5, "sand_bath", 27), (6, "retort", 27)]);
    light(&mut r, q);
    r.tick(700);
    assert_eq!(slot(&r, &qn, 7), Some((format!("{MOD}:quicksilver"), 27 * 9)), "nine quicksilver from a block of ore");

    // Putrefaction: three days of Maria's bath in the Egg.
    let insight: i32 = r.ask("t insight").parse().unwrap();
    let p = (84, 64, 80);
    let pn = athanor(&mut r, p, &[(1, "tiamat_default_world:coal", 27 * 5), (2, "conjoined_matter", 27),
        (5, "bain_marie", 27), (6, "philosophers_egg", 27)]);
    light(&mut r, p);
    r.tick(5300);
    assert_eq!(slot(&r, &pn, 7), None, "not before three days");
    r.tick(300);
    assert_eq!(slot(&r, &pn, 7), Some((format!("{MOD}:caput_corvi"), 27)), "the Raven's Head");
    let after: i32 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - insight, 125, "Gate V: Putrefaction");

    // Washed in the Egg, it shimmers while it works.
    r.boxes.set(&pn, 7, None);
    r.boxes.set(&pn, 2, Some(tiamat_core::inventory::Stack::new(r.material("caput_corvi"), 27).unwrap()));
    r.boxes.set(&pn, 3, Some(tiamat_core::inventory::Stack::new(r.material("distilled_vinegar"), 27).unwrap()));
    r.bursts();
    r.tick(200);
    assert!(!r.bursts().is_empty(), "the Egg shimmers");
    r.heard(PLAYER);
    r.tick(1700);
    assert_eq!(slot(&r, &pn, 7), Some((format!("{MOD}:peacock_matter"), 27)), "the Peacock's Tail");
    let heard = r.heard(PLAYER);
    assert!(heard.iter().any(|l| l == "Discovered: The Egg shimmers like a peacock's tail (+10 insight)"), "{heard:?}");
    println!("nigredo: ok");
}

/// A phosphorus spill lights a fuelled kiln as a striker would; theriac is
/// Life's own antidote.
fn spills_and_theriac() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.theriac", "magic.phosphorus"]);
    let at = (90, 64, 90);
    r.put_block(at.0, at.1, at.2, "tiamat_default_craft:kiln");
    r.inventory.held.lock().unwrap().remove(&PLAYER);
    assert!(r.use_at(PLAYER, at.0, at.1, at.2), "Craft opens the kiln");
    r.boxes.holders.lock().unwrap().clear();
    let kiln = format!("tiamat_default_craft:kiln:{},{},{}", at.0, at.1, at.2);
    r.boxes.set(&kiln, 1, Some(tiamat_core::inventory::Stack::new(r.material("tiamat_default_world:coal"), 27).unwrap()));
    r.give(PLAYER, "phosphorus_spill", 27 * 2);
    r.hold(PLAYER, "phosphorus_spill");
    assert!(r.use_at(PLAYER, at.0, at.1, at.2), "the spill is struck");
    assert_eq!(r.units(PLAYER, "phosphorus_spill"), 27, "one spill used");
    let lit = r.material("tiamat_default_craft:kiln_lit");
    assert_eq!(r.world.blocks.lock().unwrap().get(&at).map(|b| b.0), Some(lit), "the kiln burns");

    r.give(PLAYER, "tincture_sol", 27);
    r.give(PLAYER, "tiamat_default_life:honey", 27);
    r.give(PLAYER, "principle_salt", 27);
    assert_eq!(r.ask(&format!("t make {MOD}:theriac")), "made");
    assert_eq!(r.units(PLAYER, "tiamat_default_life:antidote"), 27, "Galen's antidote");
    println!("spills and theriac: ok");
}

/// A seed of Diana, planted on stone, is one cell of silver; unwatered it
/// waits, watered with aqua fortis it grows a cell every 2,000 ticks,
/// trunk first; dug, it is forgotten.
fn tree_of_diana() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.arbor_dianae"]);
    let ground = (110, 64, 110);
    let at = (110, 65, 110);
    r.put_block(ground.0, ground.1, ground.2, "tiamat_default_world:stone");
    r.give(PLAYER, "arbor_seed", 27);
    r.hold(PLAYER, "arbor_seed");
    assert!(r.use_at(PLAYER, ground.0, ground.1, ground.2), "planted");
    assert_eq!(r.units(PLAYER, "arbor_seed"), 0);
    let tree = r.material("arbor_dianae");
    let cells = |r: &Rig| r.world.blocks.lock().unwrap().get(&at).filter(|b| b.0 == tree).map(|b| b.1.count_ones());
    assert_eq!(cells(&r), Some(1), "one cell, at the bottom of the middle");
    assert_eq!(r.world.blocks.lock().unwrap().get(&at).unwrap().1, 1 << 10);

    r.tick(4100);
    assert_eq!(cells(&r), Some(1), "unwatered, it waits");

    r.give(PLAYER, "aqua_fortis", 27);
    r.hold(PLAYER, "aqua_fortis");
    assert!(r.use_at(PLAYER, at.0, at.1, at.2), "watered");
    assert_eq!(r.units(PLAYER, "aqua_fortis"), 0);
    r.tick(4100);
    assert_eq!(cells(&r), Some(3), "a cell every 2,000 ticks");
    let mask = r.world.blocks.lock().unwrap().get(&at).unwrap().1;
    assert_eq!(mask, (1 << 10) | (1 << 13) | (1 << 16), "the trunk first");

    r.dig_event(PLAYER, at);
    assert!(r.stored(&format!("tree:{},{},{}", at.0, at.1, at.2)).is_none(), "dug, forgotten");
    println!("tree of diana: ok");
}

/// Talismans: struck at the anvil (the recipe, gated); worn, Mercury's is
/// quick feet through Life and Saturn's makes ore nearby glint for the
/// wearer alone; taken off, Mercury's speed is taken off too.
fn talismans() {
    rig::ABILITIES.lock().unwrap().clear();
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 0);
    let answer = r.ask(&format!("t can {MOD}:talisman_sol"));
    assert!(answer.starts_with("nil") && !answer.contains("no such"), "the anvil recipe, gated: {answer}");

    r.give_view(PLAYER, "tiamat_default_life:worn", "talisman_mercury", 27);
    r.give_view(PLAYER, "tiamat_default_life:worn", "talisman_saturn", 27);
    // Saturn counts only if it is the one that counts: with one slot, the
    // first worn. So wear Saturn alone first.
    r.inventory.views.lock().unwrap().remove(&(PLAYER, "tiamat_default_life:worn".to_owned()));
    r.give_view(PLAYER, "tiamat_default_life:worn", "talisman_saturn", 27);
    r.put_block(101, 64, 101, "tiamat_default_world:iron_ore");
    r.bursts();
    r.tick(400);
    let glints: Vec<_> = r.bursts().into_iter().filter(|b| b.contains("player: Some") && b.contains("pos: [101.5")).collect();
    assert!(!glints.is_empty(), "the ore glints for the wearer");

    r.inventory.views.lock().unwrap().remove(&(PLAYER, "tiamat_default_life:worn".to_owned()));
    r.give_view(PLAYER, "tiamat_default_life:worn", "talisman_mercury", 27);
    r.tick(60);
    // Life composes it with its own (the cold slows this player), so the
    // test is the ratio: worn, a tenth quicker than without.
    let last_speed = || {
        rig::ABILITIES.lock().unwrap().iter().rev().find(|(p, _)| *p == PLAYER).and_then(|(_, a)| a.as_ref().map(|a| a.speed))
    };
    let worn = last_speed().expect("Life set a speed");
    r.inventory.views.lock().unwrap().remove(&(PLAYER, "tiamat_default_life:worn".to_owned()));
    r.tick(60);
    let bare = last_speed().expect("and set it again");
    assert!((worn / bare - 1.1).abs() < 0.01, "Mercury: a tenth quicker ({worn} against {bare})");
    println!("talismans: ok");
}

/// A Hermetic Seal wards its ground against another player's digging and
/// building, not its setter's; another's seal may not overlap it.
fn the_seal() {
    const SEAL: u32 = 134151167;
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.seven_metals", "magic.sigils", "magic.glassblowing", "magic.hermetic_seal"]);
    r.join(OTHER);
    r.tick(1);
    let seal = (130, 64, 130);
    assert!(r.place_event(PLAYER, seal, "tiamat_default_world:stone", SEAL), "set");
    r.put_carved(seal.0, seal.1, seal.2, "tiamat_default_world:stone", SEAL);
    assert!(r.stored(&format!("seal:{},{},{}", seal.0, seal.1, seal.2)).is_some());

    // Remove the operator's pass from the setter, so the test is honest.
    r.huds.operators.lock().unwrap().clear();
    let near = (133, 64, 131);
    r.put_block(near.0, near.1, near.2, "tiamat_default_world:dirt");
    assert!(!r.place_event(OTHER, (134, 64, 130), "tiamat_default_world:dirt", 0x7FF_FFFF), "another may not build");
    let (allowed, why) = r.dig_start_event(OTHER, near);
    assert!(!allowed, "nor dig");
    assert_eq!(why.as_deref(), Some("A Hermetic Seal wards this place."));
    let (allowed, _) = r.dig_start_event(PLAYER, near);
    assert!(allowed, "its setter may");
    assert!(r.place_event(OTHER, (150, 64, 130), "tiamat_default_world:dirt", 0x7FF_FFFF), "beyond it, anyone may");
    println!("the seal: ok");
}

/// Eight ouroboros blocks round a burning athanor, set by an adept who
/// knows the Ouroboros, shorten its work.
fn ouroboros() {
    const OUROBOROS: u32 = 14700600;
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.seven_metals",
        "magic.sigils", "magic.pelican", "magic.ouroboros"]);
    let fuel = ("tiamat_default_world:coal", 27 * 4);
    let with = (150, 64, 150);
    let without = (160, 64, 160);
    let a = athanor(&mut r, with, &[(1, fuel.0, fuel.1), (2, "tiamat_default_craft:copper_ingot", 27),
        (5, "tiamat_default_craft:bellows", 27)]);
    let b = athanor(&mut r, without, &[(1, fuel.0, fuel.1), (2, "tiamat_default_craft:copper_ingot", 27),
        (5, "tiamat_default_craft:bellows", 27)]);
    for (dx, dz) in [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)] {
        let at = (with.0 + dx, with.1, with.2 + dz);
        assert!(r.place_event(PLAYER, at, "tiamat_default_world:stone", OUROBOROS));
        r.put_carved(at.0, at.1, at.2, "tiamat_default_world:stone", OUROBOROS);
    }
    light(&mut r, with);
    light(&mut r, without);
    r.tick(520);
    assert_eq!(slot(&r, &a, 7), Some((format!("{MOD}:aes_ustum"), 27)), "the serpent hurries it");
    assert_eq!(slot(&r, &b, 7), None, "not yet, without one");
    println!("ouroboros: ok");
}

/// The undine: found in still water at night, bound with rosewater; it
/// takes a whole block of water from where it stands and gives it back as a
/// bucket; a second familiar bound, the first rests.
fn undine() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.salamander",
        "magic.bain_marie", "magic.undine"]);
    let model = format!("{MOD}:undine");
    // A pond's surface under the player's feet. The fake world keeps no
    // fluid kinds, so the weather's puddle rules can empty it; it is filled
    // again every tick, as a real pond would still be there.
    let pond = |r: &mut Rig, ticks: u32| {
        for _ in 0..ticks {
            r.put_water(100, 60, 100);
            r.tick(1);
        }
    };
    *r.sounds.time.lock().unwrap() = 0.5;
    pond(&mut r, 700);
    assert!(r.with_model(&model).is_empty(), "not by day");
    *r.sounds.time.lock().unwrap() = 0.9;
    r.heard(PLAYER);
    pond(&mut r, 700);
    let wild = r.with_model(&model);
    assert_eq!(wild.len(), 1, "at night, in still water");
    assert!(r.heard(PLAYER).iter().any(|l| l == "Something moves in the still water."));

    r.give(PLAYER, "rosewater", 27);
    r.hold(PLAYER, "rosewater");
    assert!(r.use_entity(PLAYER, wild[0]).0, "bound");
    assert_eq!(r.ask("magic familiar"), "Your familiars: undine (walking).");

    // It stands in water: it takes the block, and gives it as a bucket.
    let id = wild[0];
    {
        let mut map = r.entities.0.lock().unwrap();
        map.get_mut(&id).unwrap().transform = tiamat_core::ent::Transform::from_world(120.5, 61.0, 120.5);
    }
    r.put_water(120, 61, 120);
    r.tick(10);
    assert!(r.world.fluids.lock().unwrap().get(&(120, 61, 120)).is_none(), "the water is taken, not copied");
    r.give(PLAYER, "tiamat_default_life:bucket", 27);
    r.hold(PLAYER, "tiamat_default_life:bucket");
    assert!(r.use_entity(PLAYER, id).0);
    assert_eq!(r.units(PLAYER, "tiamat_default_life:water_bucket"), 27, "a bucket of it");
    assert_eq!(r.units(PLAYER, "tiamat_default_life:bucket"), 0);
    r.give(PLAYER, "tiamat_default_life:bucket", 27);
    let (_, said) = r.use_entity(PLAYER, id);
    assert_eq!(said.as_deref(), Some("It has no water to give."), "and it gave all it had");
    println!("undine: ok");
}

/// The gnome, found deep and bound with silver, makes ore glint round its
/// master; the sylph comes in a storm, and one familiar walks at a time.
fn gnome_and_sylph() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.salamander",
        "magic.cupellation", "magic.gnome", "magic.aludel", "magic.sylph"]);
    // Down in the Gloam: the first depth the world calls its dark caves.
    // The Spindle's ground at its heart is some forty thousand blocks up.
    let deep = (0..400).map(|i| 40_000 - 100 * i).find(|y| r.ask(&format!("t band 100 {y} 100")) == "dark_caves")
        .expect("the world has a Gloam");
    r.stand(PLAYER, 100.5, deep as f64 - 50.0, 100.5);
    r.tick(700);
    let gnomes = r.with_model(&format!("{MOD}:gnome"));
    assert_eq!(gnomes.len(), 1, "a gnome in the deep");
    r.give(PLAYER, "silver_grain", 27);
    r.hold(PLAYER, "silver_grain");
    assert!(r.use_entity(PLAYER, gnomes[0]).0, "bound");
    r.put_block(102, deep - 50, 101, "tiamat_default_world:iron_ore");
    r.bursts();
    r.tick(400);
    assert!(r.bursts().iter().any(|b| b.contains("player: Some") && b.contains("pos: [102.5")), "ore glints");

    // Up in a storm, a sylph; bound, it walks and the gnome rests.
    r.stand(PLAYER, 100.5, 64.0, 100.5);
    assert!(r.ask("/weather set storm 30").starts_with("storm over square"));
    r.tick(1400);
    let sylphs = r.with_model(&format!("{MOD}:sylph"));
    assert_eq!(sylphs.len(), 1, "a sylph in the storm");
    r.give(PLAYER, "aqua_vitae", 27);
    r.hold(PLAYER, "aqua_vitae");
    assert!(r.use_entity(PLAYER, sylphs[0]).0, "bound");
    assert_eq!(r.ask("magic familiar"), "Your familiars: gnome (resting), sylph (walking).");
    assert!(r.with_model(&format!("{MOD}:gnome")).is_empty(), "the gnome rests");
    assert_eq!(r.ask("magic familiar gnome"), "Your gnome walks with you.");
    assert_eq!(r.with_model(&format!("{MOD}:gnome")).len(), 1);
    assert!(r.with_model(&format!("{MOD}:sylph")).is_empty(), "and the sylph rests");
    // K calls the next: after the gnome, the sylph.
    r.heard(PLAYER);
    r.action(PLAYER, &format!("{MOD}:familiar"));
    assert_eq!(r.said(), "Your sylph walks with you.", "on K");
    assert_eq!(r.with_model(&format!("{MOD}:sylph")).len(), 1);
    println!("gnome and sylph: ok");
}

/// Quintessence: no bar off the path; from the Oath a ceiling of 10 that
/// fills a point every 200 ticks; a drink fills it to the ceiling; the
/// Fifth Essence raises the ceiling.
fn quintessence() {
    let mut r = Rig::new(Setup::default());
    ready(&mut r, 0);
    assert_eq!(r.ask("t q"), "0/0", "no bar off the path");
    adept(&mut r, &[]);
    r.tick(1);
    assert_eq!(r.ask("t q"), "0/10", "from the Oath, an empty well of ten");
    r.tick(600);
    assert_eq!(r.ask("t q"), "3/10", "a point every 200 ticks");
    r.give(PLAYER, "quintessence", 27);
    r.hold(PLAYER, "quintessence");
    assert!(r.use_at_nothing(PLAYER), "drunk");
    assert_eq!(r.ask("t q"), "10/10", "filled, to its ceiling");
    assert!(r.ask("progress grant magic.quintessence").starts_with("Learned"));
    assert_eq!(r.ask("t q"), "10/30", "the Fifth Essence deepens it");
    println!("quintessence: ok");
}

/// The Albedo: seven philosophical days in the Egg make the White Stone;
/// projected on nine tin ingots it makes nine of silver, a first
/// transmutation is a milestone, and with Atalanta Fugiens known, an emblem.
fn the_white_stone() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.bain_marie", "magic.albedo", "magic.atalanta_fugiens"]);
    let at = (170, 64, 170);
    let name = athanor(&mut r, at, &[(1, "tiamat_default_world:coal", 27 * 8), (2, "peacock_matter", 27),
        (3, "fixed_mercury", 27), (4, "tincture_luna", 27), (5, "bain_marie", 27), (6, "philosophers_egg", 27)]);
    light(&mut r, at);
    r.tick(12400);
    assert_eq!(slot(&r, &name, 7), None, "not before seven days");
    r.tick(400);
    assert_eq!(slot(&r, &name, 7), Some((format!("{MOD}:white_stone"), 27)), "the White Stone");

    r.give(PLAYER, "white_stone", 27);
    r.give(PLAYER, "tiamat_default_craft:tin_ingot", 27 * 9);
    r.heard(PLAYER);
    r.say(&format!("t make {MOD}:projection_white"));
    let heard = r.heard(PLAYER);
    assert_eq!(heard.last().map(String::as_str), Some("made"));
    assert_eq!(r.units(PLAYER, "tiamat_default_craft:silver_ingot"), 27 * 9, "nine of silver");
    assert_eq!(r.units(PLAYER, "white_stone"), 0, "the Stone is spent");
    assert!(heard.iter().any(|l| l == "Discovered: A first transmutation (+200 insight)"), "{heard:?}");
    assert!(heard.iter().any(|l| l.starts_with("Discovered: Emblem XXI")), "{heard:?}");
    println!("the white stone: ok");
}

/// The Caduceus: Hermes' Stride carries its holder along the way they face
/// for five quintessence; an elixir used on a friend is theirs, for ten.
fn caduceus() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.quintessence", "magic.caduceus"]);
    r.join(OTHER);
    r.give(PLAYER, "quintessence", 27);
    r.hold(PLAYER, "quintessence");
    assert!(r.use_at_nothing(PLAYER));
    assert_eq!(r.ask("t q"), "20/30");

    let before = r.where_is(PLAYER);
    r.give(PLAYER, "caduceus", 27);
    r.hold(PLAYER, "caduceus");
    rig::MOVES.lock().unwrap().clear();
    assert!(r.use_at_nothing(PLAYER), "the Stride");
    let after = rig::MOVES.lock().unwrap().iter().rev().find(|(p, _)| *p == PLAYER).map(|m| m.1).expect("a move");
    let moved = ((after[0] - before[0]).powi(2) + (after[2] - before[2]).powi(2)).sqrt();
    assert!(moved > 6.0, "a long step: {before:?} -> {after:?}");
    assert_eq!(r.ask("t q"), "15/30", "for five");

    r.give(PLAYER, "elixir_vigour", 27);
    r.hold(PLAYER, "elixir_vigour");
    r.heard(OTHER);
    let (handled, _) = r.use_entity_of(PLAYER, 2, Some(OTHER));
    assert!(handled, "given");
    assert_eq!(r.units(PLAYER, "elixir_vigour"), 0, "the elixir is theirs now");
    assert_eq!(r.ask("t q"), "5/30", "for ten");
    assert!(r.heard(OTHER).iter().any(|l| l == "Somebody shares an elixir with you."));
    println!("caduceus: ok");
}

/// The elementals' second gifts, with the Circle of Four (two walk at once):
/// the gnome tunnels through the world's ground and gives its master what it
/// dug; the sylph lends wings for quintessence.
fn the_gifts() {
    rig::ABILITIES.lock().unwrap().clear();
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.salamander",
        "magic.cupellation", "magic.gnome", "magic.aludel", "magic.sylph", "magic.bain_marie", "magic.undine",
        "magic.elemental_circle", "magic.gnome_delving", "magic.sylph_flight", "magic.quintessence"]);
    let deep = (0..400).map(|i| 40_000 - 100 * i).find(|y| r.ask(&format!("t band 100 {y} 100")) == "dark_caves")
        .expect("the world has a Gloam");
    r.stand(PLAYER, 100.5, deep as f64, 100.5);
    r.tick(700);
    let gnome = r.with_model(&format!("{MOD}:gnome"))[0];
    r.give(PLAYER, "silver_grain", 27);
    r.hold(PLAYER, "silver_grain");
    assert!(r.use_entity(PLAYER, gnome).0);

    r.stand(PLAYER, 100.5, 64.0, 100.5);
    assert!(r.ask("/weather set storm 30").starts_with("storm over square"));
    r.tick(1400);
    let sylph = r.with_model(&format!("{MOD}:sylph"))[0];
    r.give(PLAYER, "aqua_vitae", 27);
    r.hold(PLAYER, "aqua_vitae");
    assert!(r.use_entity(PLAYER, sylph).0);
    assert_eq!(r.ask("magic familiar"), "Your familiars: gnome (walking), sylph (walking).", "two walk, with the Circle");

    // The gnome tunnels: stone ahead of its master is dug and given to them.
    let pos = r.where_is(PLAYER);
    let (x, y, z) = (pos[0].floor() as i32, pos[1].floor() as i32, pos[2].floor() as i32);
    for step in 1..=3 {
        r.put_block(x, y, z + step, "tiamat_default_world:stone");
        r.put_block(x, y + 1, z + step, "tiamat_default_world:stone");
    }
    r.put_block(x, y, z + 4, "tiamat_default_craft:chest");
    r.inventory.held.lock().unwrap().remove(&PLAYER);
    let (handled, said) = r.use_entity(PLAYER, gnome);
    assert!(handled);
    assert_eq!(said.as_deref(), Some("The gnome digs 6 blocks, and stops."), "stopped by what somebody built");
    assert_eq!(r.units(PLAYER, "tiamat_default_world:stone"), 27 * 6, "the stone is its master's");

    // The sylph's wings, for ten quintessence.
    r.give(PLAYER, "quintessence", 27);
    r.hold(PLAYER, "quintessence");
    assert!(r.use_at_nothing(PLAYER));
    r.inventory.held.lock().unwrap().remove(&PLAYER);
    let (handled, said) = r.use_entity(PLAYER, sylph);
    assert!(handled);
    assert_eq!(said.as_deref(), Some("The sylph lifts you."));
    r.tick(20);
    assert!(rig::ABILITIES.lock().unwrap().iter().any(|(p, a)| *p == PLAYER && a.as_ref().is_some_and(|a| a.fly)), "flying");
    println!("the gifts: ok");
}

/// The Rubedo: forty philosophical days in the Egg (hurried here by Craft's
/// add_progress, as a sigil would) make the Red Stone; projected on nine
/// base ingots it makes nine of gold, and eighteen once the Stone is exalted.
fn the_red_stone() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.bain_marie", "magic.rubedo", "magic.gate_exaltation"]);
    let at = (180, 64, 180);
    let name = athanor(&mut r, at, &[(1, "tiamat_default_world:coal", 27 * 60), (2, "solar_sulfur", 27),
        (3, "ferment", 27), (4, "white_stone", 27), (5, "bain_marie", 27), (6, "philosophers_egg", 27)]);
    light(&mut r, at);
    r.tick(40);
    assert_eq!(r.ask(&format!("t hurry {name} 71900")), "true", "the athanor has the Rubedo in hand");
    r.tick(200);
    assert_eq!(slot(&r, &name, 7), Some((format!("{MOD}:red_stone"), 27)), "the Red Stone");

    r.give(PLAYER, "red_stone", 27);
    r.give(PLAYER, "tiamat_default_craft:copper_ingot", 27 * 9);
    assert_eq!(r.ask(&format!("t make {MOD}:projection_red")), "made");
    assert_eq!(r.units(PLAYER, "tiamat_default_craft:gold_ingot"), 27 * 18, "nine of gold, and nine more exalted");
    println!("the red stone: ok");
}

/// The alkahest melts the world's rock round where it is poured into prima
/// materia, a quintessence a block; coagula makes it stone again. The
/// Panacea reaches the players near its drinker.
fn alkahest_and_panacea() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.quintessence", "magic.alkahest", "magic.prima_materia", "magic.panacea"]);
    r.join(OTHER);
    r.give(PLAYER, "quintessence", 27);
    r.hold(PLAYER, "quintessence");
    assert!(r.use_at_nothing(PLAYER));
    let centre = (200, 64, 200);
    for (dx, dy, dz) in [(0, 0, 0), (1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, 0, 1)] {
        r.put_block(centre.0 + dx, centre.1 + dy, centre.2 + dz, "tiamat_default_world:stone");
    }
    r.put_block(centre.0, centre.1 - 1, centre.2, "tiamat_default_craft:chest");
    r.give(PLAYER, "alkahest", 27);
    r.hold(PLAYER, "alkahest");
    assert!(r.use_at(PLAYER, centre.0, centre.1, centre.2));
    assert_eq!(r.units(PLAYER, "prima_materia"), 27 * 5, "five blocks of first matter");
    assert_eq!(r.ask("t q"), "15/30", "a quintessence a block");
    assert!(r.world.blocks.lock().unwrap().get(&(centre.0, centre.1 - 1, centre.2)).is_some_and(|b| b.1 != 0),
        "the chest is not rock");
    assert_eq!(r.ask(&format!("t make {MOD}:coagula_stone")), "made");
    assert_eq!(r.units(PLAYER, "tiamat_default_world:stone"), 27, "unit for unit");

    r.give(PLAYER, "panacea", 27);
    r.hold(PLAYER, "panacea");
    r.heard(OTHER);
    r.tick(20);                                   // Life's cooldown between one use and the next
    assert!(r.use_at_nothing(PLAYER), "drunk");
    assert!(r.heard(OTHER).iter().any(|l| l == "The Panacea's warmth reaches you."));
    println!("alkahest and panacea: ok");
}

/// The Phoenix keeps a player's things once in three sun-days; the
/// Chymical Wedding crowns whoever completes it.
fn phoenix_and_wedding() {
    const SOL: u32 = 16612927;
    const LUNA: u32 = 83853119;
    const QUINTESSENCE: u32 = 4289552;
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.phoenix", "magic.chymical_wedding"]);
    let armed = format!("phoenix:{}", rig::hex(PLAYER));
    assert_eq!(r.stored(&armed).as_deref(), Some("Flag(true)"), "armed when learned");
    r.heard(PLAYER);
    r.say("die");
    assert!(r.heard(PLAYER).iter().any(|l| l == "The phoenix rises: you keep what you carried."));
    assert!(r.stored(&armed).is_none(), "spent");
    r.tick(1300);
    assert!(r.stored(&armed).is_none(), "not again for three sun-days");

    let at = (210, 64, 210);
    athanor(&mut r, at, &[]);
    for (pos, id, mask) in [((211, 64, 210), "tiamat_default_world:gold_ore", SOL), ((209, 64, 210), "tiamat_default_world:silver_ore", LUNA),
        ((210, 65, 210), "tiamat_default_world:crystal", QUINTESSENCE)] {
        assert!(r.place_event(PLAYER, pos, id, mask));
        r.put_carved(pos.0, pos.1, pos.2, id, mask);
    }
    r.tick(220);
    assert_eq!(r.units(PLAYER, "wedding_crown"), 27, "the Red King and the White Queen joined");
    r.tick(220);
    assert_eq!(r.units(PLAYER, "wedding_crown"), 27, "once");
    println!("phoenix and wedding: ok");
}

/// The homunculus, woken from its vial: it keeps an athanor near it in coal
/// from a chest near it, a block a turn, and opens its satchel to its
/// master; an essence given to it is a trait. The basilisk hatches from its
/// egg and walks too, with the Greater Elementals' third place.
fn homunculus_and_basilisk() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.homunculus", "magic.basilisk", "magic.essentia_animalium", "magic.elemental_circle",
        "magic.greater_elementals"]);
    r.give(PLAYER, "homunculus_vial", 27);
    r.hold(PLAYER, "homunculus_vial");
    assert!(r.use_at_nothing(PLAYER), "woken");
    let model = format!("{MOD}:homunculus");
    assert_eq!(r.with_model(&model).len(), 1, "it walks with its master");
    let helper = r.with_model(&model)[0];

    // A chest of coal and a cold athanor, both near it.
    let chest = "tiamat_default_craft:chest:103,64,103".to_owned();
    r.boxes.slots.lock().unwrap().insert(chest.clone(), vec![None; 27]);
    r.boxes.set(&chest, 1, Some(tiamat_core::inventory::Stack::new(r.material("tiamat_default_world:coal"), 27 * 3).unwrap()));
    let name = athanor(&mut r, (104, 64, 101), &[]);
    r.tick(60);
    assert_eq!(slot(&r, &name, 1), Some(("tiamat_default_world:coal".to_owned(), 27)), "a block of fuel");
    r.tick(60);
    assert_eq!(slot(&r, &name, 1), Some(("tiamat_default_world:coal".to_owned(), 81)), "a block every 40 ticks");
    assert_eq!(r.boxes.get(&chest, 1), None, "until the chest is empty");

    r.inventory.held.lock().unwrap().remove(&PLAYER);
    assert!(r.use_entity(PLAYER, helper).0, "its satchel");
    assert!(r.boxes.exists(&format!("{MOD}:satchel:{}", rig::hex(PLAYER))));

    r.give_detail(PLAYER, "beast_essence", 27, "k=horse");
    let (_, said) = r.use_entity(PLAYER, helper);
    assert_eq!(said.as_deref(), Some("Your homunculus takes the horse's essence."));
    assert_eq!(r.stored(&format!("traits:{}:homunculus", rig::hex(PLAYER))).as_deref(), Some("Text(\"horse\")"));
    assert_eq!(r.with_model(&model).len(), 1, "made again, with its trait");

    r.give(PLAYER, "basilisk_egg", 27);
    r.hold(PLAYER, "basilisk_egg");
    assert!(r.use_at_nothing(PLAYER), "hatched");
    assert_eq!(r.with_model(&format!("{MOD}:basilisk")).len(), 1, "three may walk now");
    println!("homunculus and basilisk: ok");
}

/// The microcosm: the Egg in hand makes its owner's island (an instance
/// keyed by their UUID) and takes them there, and back to where they stood.
/// Two correspondence gates, linked with a quintessence, carry a walker
/// from one to the other for five more.
fn microcosm_and_gates() {
    const EMERALD: u32 = 50331327;
    const SOL: u32 = 16612927;
    const LUNA: u32 = 83853119;
    rig::TRANSFERS.lock().unwrap().clear();
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.quintessence", "magic.prima_materia", "magic.microcosm", "magic.as_above_so_below"]);
    let island = format!("{MOD}:microcosm/{}", &rig::hex(PLAYER)[..16]);
    r.give(PLAYER, "philosophers_egg", 27);
    r.hold(PLAYER, "philosophers_egg");
    assert!(r.use_at_nothing(PLAYER), "into the Egg");
    assert!(r.places.0.lock().unwrap().contains(&island), "their island, made");
    let went = rig::TRANSFERS.lock().unwrap().last().cloned().expect("a transfer");
    assert_eq!((went.0, went.1.as_str()), (1, island.as_str()), "the player, to their island");
    let out = tiamat_core::script::ScriptVm::use_block(&mut r.vm, &tiamat_core::script::UseEvent { player: PLAYER, domain: island.clone(), aim: None,
        held: tiamat_core::inventory::Access::held(&*r.inventory, PLAYER) });
    assert!(!out.allowed, "and the Egg, used there");
    let back = rig::TRANSFERS.lock().unwrap().last().cloned().expect("a transfer back");
    assert_eq!(back.1, "overworld", "back where they came from");
    assert!((back.2[0] - 100.5).abs() < 0.01 && (back.2[2] - 100.5).abs() < 0.01, "to where they stood: {back:?}");

    // Two gates: an emerald, Sol on one diagonal, Luna on the other.
    for (cx, cz) in [(220, 220), (240, 240)] {
        r.put_carved(cx, 64, cz, "tiamat_default_world:crystal", EMERALD);
        for (dx, dz, mask, id) in [(1, 1, SOL, "tiamat_default_world:gold_ore"), (-1, -1, SOL, "tiamat_default_world:gold_ore"),
            (1, -1, LUNA, "tiamat_default_world:silver_ore"), (-1, 1, LUNA, "tiamat_default_world:silver_ore")] {
            r.put_carved(cx + dx, 64, cz + dz, id, mask);
        }
    }
    r.give(PLAYER, "quintessence", 27 * 3);
    r.hold(PLAYER, "quintessence");
    assert!(r.use_at_nothing(PLAYER), "a drink, for the well");
    r.tick(20);
    assert!(r.use_at(PLAYER, 220, 64, 220), "the first gate hums");
    assert!(r.use_at(PLAYER, 240, 64, 240));
    assert_eq!(r.units(PLAYER, "quintessence"), 27, "one spent on the link");
    rig::MOVES.lock().unwrap().clear();
    r.moved(PLAYER, (220, 65, 220));
    let carried = rig::MOVES.lock().unwrap().last().cloned().expect("carried");
    assert_eq!(carried.1, [240.5, 65.0, 240.5], "set down on the twin");
    println!("microcosm and gates: ok");
}

/// A Tree of Diana grown whole, with a Venus sigil three blocks off on each
/// side set by a gardener who knows the Rosarium: flowers bloom on its grass.
fn rose_garden() {
    const VENUS: u32 = 100433791;
    let mut r = Rig::new(Setup::default());
    let tree = (230, 65, 230);
    // A grown tree, as storage keeps one, before the world first looks.
    r.storage.0.lock().unwrap().insert((MOD.to_owned(), format!("tree:{},{},{}", tree.0, tree.1, tree.2)),
        tiamat_core::storage::Value::Text(format!("27;{}", rig::hex(PLAYER))));
    adept(&mut r, &["magic.rosarium"]);
    r.put_block(tree.0, tree.1, tree.2, "arbor_dianae");
    for dx in -3..=3 {
        for dz in -3..=3 {
            r.put_block(tree.0 + dx, tree.1 - 1, tree.2 + dz, "tiamat_default_world:grass");
        }
    }
    for (dx, dz) in [(3, 0), (-3, 0), (0, 3), (0, -3)] {
        let at = (tree.0 + dx, tree.1, tree.2 + dz);
        assert!(r.place_event(PLAYER, at, "tiamat_default_world:stone", VENUS));
        r.put_carved(at.0, at.1, at.2, "tiamat_default_world:stone", VENUS);
    }
    r.tick(1300);
    let flowers: Vec<_> = r.world.edits.lock().unwrap().iter()
        .filter(|(p, id)| p.y == tree.1 && (id.ends_with("chamomile") || id.ends_with("poppy") || id.ends_with("bluebell")
            || id.ends_with("peony") || id.ends_with("allium")))
        .cloned().collect();
    assert!(!flowers.is_empty(), "flowers bloom in the Rose Garden");
    println!("rose garden: ok");
}

/// Gate XII: a Red Stone and twenty quintessence used on the ground turn the
/// base-metal ore round it into gold ore, a block a tick, and leave common
/// stone alone; the Gate is a discovery worth 300.
fn world_projection_and_the_assay() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.quintessence", "magic.gate_projection"]);
    r.give(PLAYER, "quintessence", 27);
    r.hold(PLAYER, "quintessence");
    assert!(r.use_at_nothing(PLAYER), "a drink, for the well");
    r.tick(20);
    let centre = (250, 64, 250);
    r.put_block(centre.0, centre.1, centre.2, "tiamat_default_world:stone");
    for (dx, dz) in [(1, 0), (-1, 1), (2, 2)] {
        r.put_block(centre.0 + dx, centre.1, centre.2 + dz, "tiamat_default_world:copper_ore");
    }
    r.put_block(centre.0 + 3, centre.1, centre.2, "tiamat_default_world:copper_ore");
    let before: i64 = r.ask("t insight").parse().unwrap();
    r.give(PLAYER, "red_stone", 27);
    r.hold(PLAYER, "red_stone");
    assert!(r.use_at(PLAYER, centre.0, centre.1, centre.2), "the Stone, thrown");
    assert_eq!(r.units(PLAYER, "red_stone"), 0, "the Stone is spent");
    assert_eq!(r.ask("t q"), "0/30", "and twenty quintessence");
    r.tick(5);
    let gold = r.material("tiamat_default_world:gold_ore");
    let copper = r.material("tiamat_default_world:copper_ore");
    let blocks = r.world.blocks.lock().unwrap().clone();
    for (dx, dz) in [(1, 0), (-1, 1), (2, 2)] {
        assert_eq!(blocks.get(&(centre.0 + dx, centre.1, centre.2 + dz)).map(|b| b.0), Some(gold), "gold ore at {dx},{dz}");
    }
    assert_eq!(blocks.get(&(centre.0 + 3, centre.1, centre.2)).map(|b| b.0), Some(copper), "beyond the radius");
    assert_ne!(blocks.get(&centre).map(|b| b.0), Some(gold), "stone is not base metal");
    let after: i64 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - before, 300, "Gate XII, discovered");
    // The Assay: Progress pays every study more, read from its key (P-M2).
    assert_eq!(r.ask("progress grant magic.assay"), "Learned: The Assay");
    assert_eq!(r.ask("t effects progress."), "progress.study_percent=25");
    println!("world projection and the assay: ok");
}

/// Lapis Infinitus: the Stone multiplies in one day, fed a quintessence.
fn lapis_infinitus() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.bain_marie", "magic.rubedo", "magic.gate_multiplication", "magic.lapis_infinitus"]);
    let at = (190, 64, 190);
    let name = athanor(&mut r, at, &[(1, "tiamat_default_world:coal", 27 * 10), (2, "red_stone", 27),
        (3, "tiamat_default_craft:gold_ingot", 27), (4, "quintessence", 27), (5, "bain_marie", 27), (6, "philosophers_egg", 27)]);
    light(&mut r, at);
    r.tick(40);
    assert_eq!(r.ask(&format!("t hurry {name} 1800")), "true", "the athanor has the work in hand");
    r.tick(200);
    assert_eq!(slot(&r, &name, 7), Some((format!("{MOD}:red_stone"), 54)), "two Stones, in a day");
    println!("lapis infinitus: ok");
}

/// Quintessences of the Four: a gnome walking with an adept who stands at
/// the centre of a Circle of Four gives up the quintessence of earth after
/// a philosophical day there.
fn quintessences_of_the_four() {
    const QUINTESSENCE: u32 = 4289552;
    const FIRE: u32 = 6127127;
    const WATER: u32 = 134143999;
    const AIR: u32 = 129928175;
    const EARTH: u32 = 49020602;
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.athanor", "magic.degrees_of_fire", "magic.gate_calcination", "magic.salamander",
        "magic.cupellation", "magic.gnome", "magic.elemental_quintessences"]);
    let deep = (0..400).map(|i| 40_000 - 100 * i).find(|y| r.ask(&format!("t band 100 {y} 100")) == "dark_caves")
        .expect("the world has a Gloam");
    let feet = deep - 50;
    r.stand(PLAYER, 100.5, feet as f64, 100.5);
    r.tick(700);
    let gnomes = r.with_model(&format!("{MOD}:gnome"));
    assert_eq!(gnomes.len(), 1, "a gnome in the deep");
    r.give(PLAYER, "silver_grain", 27);
    r.hold(PLAYER, "silver_grain");
    assert!(r.use_entity(PLAYER, gnomes[0]).0, "bound");
    let y = feet - 1;
    r.put_carved(100, y, 100, "tiamat_default_world:crystal", QUINTESSENCE);
    for (dx, dz, id, mask) in [(2, 0, "tiamat_default_world:lava_rock", FIRE), (-2, 0, "tiamat_default_world:ice", WATER),
        (0, 2, "tiamat_default_world:pumice", AIR), (0, -2, "tiamat_default_world:granite", EARTH)] {
        r.put_carved(100 + dx, y, 100 + dz, id, mask);
    }
    r.tick(1000);
    assert_eq!(r.units(PLAYER, "quintessence_earth"), 0, "not yet: half a day");
    r.tick(900);
    assert_eq!(r.units(PLAYER, "quintessence_earth"), 27, "the quintessence of earth");
    println!("quintessences of the four: ok");
}

/// The Loom: a world woven with the Rebis, its sky and vein and sea chosen;
/// the Egg back out, the Loom back in; a World-Gate for the weaver and,
/// once allowed, a friend; the world generated; and Solve et Coagula ends
/// it, with half the first matter back.
fn woven_worlds() {
    const MASKS: [(&str, u32, &str); 13] = [
        ("quintessence", 4289552, "crystal"),
        ("sol", 16612927, "gold_ore"), ("luna", 83853119, "silver_ore"), ("venus", 100433791, "copper_ore"),
        ("mars", 117374719, "iron_ore"), ("jupiter", 100433855, "tin_ore"), ("saturn", 50233279, "lead_ore"),
        ("mercury", 100597439, "cinnabar"), ("emerald", 50331327, "crystal"),
        ("fire", 6127127, "lava_rock"), ("water", 134143999, "ice"), ("air", 129928175, "pumice"), ("earth", 49020602, "granite"),
    ];
    let ring = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)];
    let edges = [(2, 0), (-2, 0), (0, 2), (0, -2)];
    rig::TRANSFERS.lock().unwrap().clear();
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.quintessence", "magic.microcosm", "magic.as_above_so_below", "magic.opus_mundi",
        "magic.planetary_skies", "magic.planetary_veins", "magic.worldgate", "magic.solve_et_coagula"]);
    let (lx, ly, lz) = (300, 64, 300);
    let carve = |r: &Rig, x: i32, z: i32, glyph: &str| {
        let (_, mask, ore) = MASKS.iter().find(|m| m.0 == glyph).unwrap();
        r.put_carved(x, ly, z, &format!("tiamat_default_world:{ore}"), *mask);
    };
    carve(&r, lx, lz, "quintessence");
    for (d, glyph) in ring.iter().zip(["sol", "luna", "venus", "mars", "jupiter", "saturn", "mercury", "emerald"]) {
        carve(&r, lx + d.0, lz + d.1, glyph);
    }
    for (d, glyph) in edges.iter().zip(["fire", "water", "air", "earth"]) {
        carve(&r, lx + d.0, lz + d.1, glyph);
    }

    // Weave: water, under Sol, rich in Mars's iron, a high sea.
    for id in ["rebis", "quintessence_fire", "quintessence_water", "quintessence_air", "quintessence_earth", "red_stone"] {
        r.give(PLAYER, id, 27);
    }
    r.give(PLAYER, "prima_materia", 27 * 27);
    r.hold(PLAYER, "rebis");
    let before: i64 = r.ask("t insight").parse().unwrap();
    assert!(r.use_at(PLAYER, lx, ly, lz));
    let (form, tree) = r.last_dialog().expect("the Loom asks");
    assert_eq!(form, format!("{MOD}:loom"));
    assert!(tree.contains("Weave a world of"), "{tree}");
    for button in ["arch:water", "sky:sol", "vein:mars", "sea:high", "weave"] {
        r.press(PLAYER, MOD, "loom", button);
    }
    let key = format!("{}_1_mars_high", &rig::hex(PLAYER)[..16]);
    let world = format!("{MOD}:world_water/{key}");
    assert!(r.places.0.lock().unwrap().contains(&world), "the world, made: {:?}", r.places.0.lock().unwrap());
    let went = rig::TRANSFERS.lock().unwrap().last().cloned().expect("a transfer");
    assert_eq!((went.0, went.1.as_str()), (1, world.as_str()), "the weaver, into it");
    for id in ["rebis", "quintessence_fire", "quintessence_water", "quintessence_air", "quintessence_earth", "red_stone", "prima_materia"] {
        assert_eq!(r.units(PLAYER, id), 0, "{id} taken");
    }
    let after: i64 = r.ask("t insight").parse().unwrap();
    assert_eq!(after - before, 1000, "the first world woven");

    // Its ground: the landing under the arrival, and a high sea far out.
    use tiamat_core::script::ScriptVm;
    let air = tiamat_core::MaterialId::AIR;
    let (chunk, _) = r.vm.generate_chunk(&world, rig::SEED, tiamat_core::BlockPos { x: 0, y: 64, z: 0 }.chunk(), air)
        .expect("the landing generates");
    assert!(chunk.blocks().any(|(_, b)| !b.is_air()), "there is ground under the arrival");
    let mut wet = false;
    for x in [2000, 3000, 4000, 5000] {
        let (_, fluid) = r.vm.generate_chunk(&world, rig::SEED, tiamat_core::BlockPos { x, y: 66, z: x }.chunk(), air)
            .expect("the sea generates");
        wet |= fluid.blocks().any(|f| f.0 != 0);
    }
    assert!(wet, "a world-wide sea");

    // The Egg, inside, goes back to where the weaver stood.
    r.give(PLAYER, "philosophers_egg", 27);
    r.hold(PLAYER, "philosophers_egg");
    let out = r.vm.use_block(&tiamat_core::script::UseEvent { player: PLAYER, domain: world.clone(), aim: None,
        held: tiamat_core::inventory::Access::held(&*r.inventory, PLAYER) });
    assert!(!out.allowed, "the Egg, used inside");
    let back = rig::TRANSFERS.lock().unwrap().last().cloned().expect("a transfer back");
    assert_eq!(back.1, "overworld");
    assert!((back.2[0] - 300.5).abs() < 0.01 && (back.2[2] - 303.5).abs() < 0.01, "beside the Loom: {back:?}");

    // The Loom, with anything else in hand, lists the world to enter.
    r.hold(PLAYER, "quintessence_air");
    assert!(r.use_at(PLAYER, lx, ly, lz));
    let (_, tree) = r.last_dialog().expect("the list");
    assert!(tree.contains("A world of Water"), "{tree}");
    r.press(PLAYER, MOD, "loom", &format!("enter:{key}"));
    assert_eq!(rig::TRANSFERS.lock().unwrap().last().map(|t| t.1.clone()), Some(world.clone()), "in again");

    // A World-Gate: a correspondence gate bound with the Egg.
    const EMERALD: u32 = 50331327;
    const SOL: u32 = 16612927;
    const LUNA: u32 = 83853119;
    let (gx, gz) = (330, 330);
    r.put_carved(gx, 64, gz, "tiamat_default_world:crystal", EMERALD);
    for (dx, dz, mask, id) in [(1, 1, SOL, "tiamat_default_world:gold_ore"), (-1, -1, SOL, "tiamat_default_world:gold_ore"),
        (1, -1, LUNA, "tiamat_default_world:silver_ore"), (-1, 1, LUNA, "tiamat_default_world:silver_ore")] {
        r.put_carved(gx + dx, 64, gz + dz, id, mask);
    }
    r.hold(PLAYER, "philosophers_egg");
    assert!(r.use_at(PLAYER, gx, 64, gz));
    assert_eq!(r.stored(&format!("worldgate:{gx},64,{gz}")).as_deref(), Some(format!("Text({key:?})").as_str()), "bound");
    rig::TRANSFERS.lock().unwrap().clear();
    r.moved(PLAYER, (gx, 65, gz));
    assert_eq!(rig::TRANSFERS.lock().unwrap().last().map(|t| t.1.clone()), Some(world.clone()), "the weaver, through the gate");
    r.join(OTHER);
    rig::TRANSFERS.lock().unwrap().clear();
    r.heard(OTHER);
    r.moved(OTHER, (gx, 65, gz));
    assert!(rig::TRANSFERS.lock().unwrap().is_empty(), "a stranger is not carried");
    assert!(r.heard(OTHER).iter().any(|l| l == "That world is not open to you."));
    assert_eq!(r.ask("magic world allow someone"), "someone may walk in your worlds.");
    r.tick(50);
    r.moved(OTHER, (gx, 65, gz));
    assert_eq!(rig::TRANSFERS.lock().unwrap().last().map(|t| t.1.clone()), Some(world.clone()), "a friend, allowed");

    // Solve et coagula.
    r.hold(PLAYER, "quintessence_air");
    assert!(r.use_at(PLAYER, lx, ly, lz));
    r.press(PLAYER, MOD, "loom", &format!("solve:{key}"));
    assert!(!r.places.0.lock().unwrap().contains(&world), "the world, ended");
    assert_eq!(r.units(PLAYER, "prima_materia"), 27 * 27 / 2, "half its first matter back");
    assert!(r.stored(&format!("woven:{key}")).is_none(), "and forgotten");
    println!("woven worlds: ok");
}

/// The Universal Medicine runs among friends without fault; Thrice-Greatest
/// shows the Tablet's whole text when it is learned, and on `magic tablet`,
/// and wears a golden aura.
fn thrice_greatest() {
    let mut r = Rig::new(Setup::default());
    adept(&mut r, &["magic.universal_medicine"]);
    r.join(OTHER);
    r.stand(OTHER, 100.5, 64.0, 102.5);
    r.tick(220);
    r.heard(OTHER);
    assert_eq!(r.ask("progress grant magic.hermes_trismegistus"), "Learned: Thrice-Greatest");
    let (form, tree) = r.last_dialog().expect("the Tablet speaks");
    assert_eq!(form, format!("{MOD}:tablet"));
    assert!(tree.contains("Tis true without lying") && tree.contains("Hermes Trismegist"), "{tree}");
    assert!(r.heard(OTHER).iter().any(|l| l.ends_with("is Trismegistus: Thrice-Greatest.")));
    assert_eq!(r.ask("magic tablet"), "", "again, on asking");
    r.bursts();
    r.tick(50);
    assert!(!r.bursts().is_empty(), "a golden aura");
    println!("thrice-greatest: ok");
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
