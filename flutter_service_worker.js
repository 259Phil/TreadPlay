'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"manifest.json": "049a6c2456a6901380e668bec65a0873",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"flutter_bootstrap.js": "8cf84e3002c0f8b17a981152e9c9b0b4",
"favicon.png": "71886486e5e1967cce90e6b4ef20faa5",
"version.json": "1fc7a298f3401418788263ed6efb0a3f",
"assets/FontManifest.json": "2d0096f7aaeb2e891722f93a746db950",
"assets/assets/worlds/robot.jpg": "3a759a1200ed4c6087cc8f04f2080e89",
"assets/assets/worlds/egypt.jpg": "d21184806468a05a3b3778aa6366ab4f",
"assets/assets/worlds/candy.jpg": "211ffe53b1e475c5726c0b241e87c554",
"assets/assets/worlds/jungle.jpg": "ee5b4d80192bb2f1173dd6fc09ef4fa6",
"assets/assets/worlds/medieval.jpg": "01ff8df5428b662e757e366e9727678f",
"assets/assets/worlds/water.jpg": "b6475e95e49c6794e242a4724f6369eb",
"assets/assets/worlds/steam.jpg": "8f903c8220d05006643a0df227c39b03",
"assets/assets/worlds/pirate.jpg": "d17386b51d30b2c9e350b633a792b68e",
"assets/assets/worlds/space.jpg": "ded2826a7a50b48b831f57675db8ce1a",
"assets/assets/worlds/rococo.jpg": "28270ae2aadd3e474c3e49fef169c91b",
"assets/assets/backdrop/bg3.jpg": "0712c6d30ad6dc5244e1a4d88d728295",
"assets/assets/backdrop/bg2.jpg": "11c7d9b3159b484d4b8dbdfb318baaff",
"assets/assets/backdrop/bg1.jpg": "0390bf68f1f4c202f15319cbff610143",
"assets/assets/forge/recipe_faehrte.webp": "a88f9ea5aee9e41dab5feefec0c16281",
"assets/assets/forge/hammer.webp": "9931b273cdf394be90a2d345e46a3bdf",
"assets/assets/forge/icon_case.webp": "a91f5ebc469164af338fea33b4ef0185",
"assets/assets/forge/combine_wax.webp": "75e7df3298eec7e71d002c4474a47420",
"assets/assets/forge/recipe_ausdauer.webp": "a7f841c1b7db95c94fb1d788aae7e2fb",
"assets/assets/forge/combine_grimoire.webp": "22fa1466280cd65013a1653e63503067",
"assets/assets/forge/icon_ladder.webp": "e3172b47cfe1ce4b9ced818990efbdbf",
"assets/assets/forge/icon_fuse.webp": "a35e72f0eacf3a56c4da08b4e1bac11e",
"assets/assets/forge/recipe_schutz.webp": "b46ccfbf81bc442fa72320af35289f46",
"assets/assets/forge/anvil_plain.webp": "c10f48df2483a982f09c9950eb41ddb1",
"assets/assets/npc/messenger_turquoise_flimm.webp": "0446ed16f5bb43dd55e0283602bc59f4",
"assets/assets/npc/messenger_navy_vesper.webp": "ffa3c9156e7db6d2cb92fe47a64ce93e",
"assets/assets/npc/messenger_brown_ruhu.webp": "6e57c50a8076cd63f69f3b3d840ea0b3",
"assets/assets/npc/messenger_copper_kolk.webp": "7026bddbd528f47e09e528d1ad4e91f6",
"assets/assets/kits/kit_master.png": "c0c33a626fff81e2876652fc41e8619f",
"assets/assets/kits/kit_light.png": "b42155a6b62730b4d3f150306df0bbae",
"assets/assets/kits/kit_solid.png": "7f0e0ffd139f435cb7cb6d746da7613f",
"assets/assets/pouch/pouch_turquoise.webp": "fb0c1340b786b70f24189e4865c51cd9",
"assets/assets/pouch/pouch_navy.webp": "cf0700722e89a5ed40928704d0d17380",
"assets/assets/pouch/pouch_brown.webp": "731831a5bbd6ad6e8c98030148539f7e",
"assets/assets/pouch/pouch_copper.webp": "d69f1d32ecd9449abc738af307ec6d97",
"assets/assets/leash/leash_ring.webp": "6e18a613ed5ad807685c76686bccb722",
"assets/assets/leash/leash_rope.webp": "a66bdcd858f8384df084627b80bb596c",
"assets/assets/leash/leash_cap_l.webp": "4552fc27f84816b02a1dd9a32fb5170e",
"assets/assets/leash/leash_cap_r.webp": "df8562df9fedd07c4794287838b694d5",
"assets/assets/companions/ringelpanz-epic.png": "db9f2c7db2f869492d20fd60bc9fa4fa",
"assets/assets/companions/porzella_c.png": "6d72adaf25d3c061fdd43e07c264a564",
"assets/assets/companions/puderling-rare.png": "70d6ce29dd5c270888917da896daadf7",
"assets/assets/companions/teerbock_c.png": "3a67015ba05856ad97fcad5a17ee96db",
"assets/assets/companions/muschlo.png": "68d722fc20415f68c87a1b9ccd3923dc",
"assets/assets/companions/segelkamm-rare.png": "21bc25d19c63eb57db21739b4cef6a53",
"assets/assets/companions/karamello-rare.png": "86b18429c88c72d7d4ec29ca80080ac1",
"assets/assets/companions/porzella.png": "ff82c3766eaa8c95ab89c34818fa92c8",
"assets/assets/companions/kraterix-rare.png": "ff157dc672b296e75aa9306cc77461cc",
"assets/assets/companions/schwammo-epic.png": "b2b894f45832c684537010f5dcc09352",
"assets/assets/companions/dune-epic.png": "e4ea493dbd4e7a08cbb0ecf7cbf6912e",
"assets/assets/companions/brine_c.png": "061c9a297edaad66d5b5e1d0301f7951",
"assets/assets/companions/vine.png": "822f0f3f2c578b362a19960e135d9199",
"assets/assets/companions/emaillo_c.png": "087bf6d94c8db211e2dd5291478a945d",
"assets/assets/companions/karamello-legendary.png": "951d2308acdae20ee537e182d8df6271",
"assets/assets/companions/zinnbuck.png": "7a7315b64013f1da8900d60d633411ed",
"assets/assets/companions/pebble-legendary.png": "e77c15be3bbf71f8da9ebf667ca3421d",
"assets/assets/companions/kraterix.png": "3bfcdadd2ce7bdde044c2463b6ebe99c",
"assets/assets/companions/teerbock-rare.png": "c12451d5128a0d295002fee94510521a",
"assets/assets/companions/porzella-rare.png": "0e9d13fceb00ce63b8d7b8ce61b87ef5",
"assets/assets/companions/pebble-rare.png": "7421c60f2a1e147d27177afaf8850757",
"assets/assets/companions/pebble_c.png": "1830bfc807987fcbef436d4c9611138e",
"assets/assets/companions/glaze-epic.png": "707bfa67c29de4a8525a73b6a675a2e8",
"assets/assets/companions/lumen-legendary.png": "21bc811db886aaffa67add9460cca45a",
"assets/assets/companions/messingor-epic.png": "5d46815aa5f804321f51b6f92f5e9a73",
"assets/assets/companions/gilt.png": "1abde43a1f989159e1f9f76ce7c3034a",
"assets/assets/companions/papyrix.png": "c7faf1b9721e51e5637576e34899ef05",
"assets/assets/companions/tangwell_c.png": "46823239f11f91d99e4aa30f3296fe95",
"assets/assets/companions/schwammo-legendary.png": "7fd37fa9393e4ee8cfede2fed4c53ecd",
"assets/assets/companions/porzella-legendary.png": "c21e39924078d0307616d4bb7bfb47ff",
"assets/assets/companions/papyrix-legendary.png": "446b176346083c82d3ad6b98539df538",
"assets/assets/companions/brine-rare.png": "56e30a0556ada74c198e5266ad8d1de5",
"assets/assets/companions/drahtel_c.png": "a99dbf28bad8f81b2b77c15779c1bf89",
"assets/assets/companions/glaze-legendary.png": "79b77bd5f1af57c8fa4d698606d49f87",
"assets/assets/companions/lakrillo-rare.png": "1dea3dbfbe885c20df2c0a6afb1eca45",
"assets/assets/companions/papyrix_c.png": "c884beb5315a4e7dec5aa4bdce660586",
"assets/assets/companions/nebulo-legendary.png": "2303eaf63e75a811e1a054a1929049e4",
"assets/assets/companions/gilt_c.png": "c5901461738c748e54a5a743f7b88822",
"assets/assets/companions/segelkamm-legendary.png": "452c6e411c35cab65db4af36924787e0",
"assets/assets/companions/vine-epic.png": "4020f9640f766feb52ce02795c7d17eb",
"assets/assets/companions/lumen.png": "a37308c117cff571e926f1ee043a5b7c",
"assets/assets/companions/emaillo-rare.png": "69e7fceb533211a4530c3298bda28d59",
"assets/assets/companions/messingor.png": "70b1f631ed72c36e73fa58cac568fbe0",
"assets/assets/companions/puderling_c.png": "b5db078ddc26f9eeebccd04eb2cfd991",
"assets/assets/companions/porzella-epic.png": "e24657323e6183d2b4b96c9a5e303e42",
"assets/assets/companions/brine-epic.png": "799d5caa2d479a402021b9c31c54f98d",
"assets/assets/companions/lapisor.png": "14f5ab07d913e48d02f7e499b1e68fb9",
"assets/assets/companions/ringelpanz-rare.png": "c4340194370486ef6598bf6b2e29cb36",
"assets/assets/companions/muschlo-epic.png": "e79695735ac72b5b647e3b9a0217fd22",
"assets/assets/companions/lakrillo-epic.png": "1780682c5b93f089fca0f38b9aab4bef",
"assets/assets/companions/drahtel-legendary.png": "0b7223c6c33c01088836503b388c5d9e",
"assets/assets/companions/glaze_c.png": "704005e7ba2f4c8d53b761f8397a9837",
"assets/assets/companions/pebble-epic.png": "a073407bb8f7e10b3efcac78b5f8e119",
"assets/assets/companions/dune-legendary.png": "a8ec7f89c83bb94d8bdae5c2d1094550",
"assets/assets/companions/kraterix-epic.png": "88f3d7cf010e874e40e892bc3ca6274b",
"assets/assets/companions/drahtel-epic.png": "627b0e64755ed035ca3bbd5d60484666",
"assets/assets/companions/karamello_c.png": "34d6fcbc21799906e5a43d70d093a913",
"assets/assets/companions/tangwell.png": "f79549e7a9e8594499d064e12bc118b8",
"assets/assets/companions/lumen-epic.png": "1c93bc7b137e3eff0e91cad8be355b25",
"assets/assets/companions/muttrix-epic.png": "f345c5c2359cdb20098ee657c99a5c84",
"assets/assets/companions/lumen_c.png": "4118111051b292e75f2a3b2b011fbdfb",
"assets/assets/companions/lumen-rare.png": "9e6a9ed5f67b2fe5d5dbbc1c4007f57f",
"assets/assets/companions/farnix.png": "31204da430ce3966f378f9759ed3c869",
"assets/assets/companions/hookfin_c.png": "e236827b1f29609cc1c579c2d0b97c03",
"assets/assets/companions/valve_c.png": "5b5f0648be55d0b55d23a630d04a1be0",
"assets/assets/companions/zinnbuck-legendary.png": "fb41044a274a76817904b883370fb25f",
"assets/assets/companions/hookfin-epic.png": "59484d62f7cc6a9ddbf52acf8d8c8acb",
"assets/assets/companions/farnix-rare.png": "3fb47e332cfd6e3ff9d188bafe4acae8",
"assets/assets/companions/gilt-rare.png": "964d4623d64883382da9d0126f6e9af0",
"assets/assets/companions/muschlo-legendary.png": "9671308104c984873d80dabe4b2547ed",
"assets/assets/companions/dune-rare.png": "cdf3c8ff80bce3a4c35cf431c96caa55",
"assets/assets/companions/glaze-rare.png": "ec8df0b8eee1103628ce8aa330bb9f01",
"assets/assets/companions/ringelpanz_c.png": "72f2b54336d25c6c71b55c92a359f9ec",
"assets/assets/companions/puderling-epic.png": "a52c3c7ef862b15cff93f7a5e3b4d90e",
"assets/assets/companions/gilt_r.png": "b58222ca6e816865d2b4861b71b90c8b",
"assets/assets/companions/vine-legendary.png": "563ffb1cbb63db37b7ced1d90266a383",
"assets/assets/companions/gilt-epic.png": "a64db5a58f9e73004aa536679c721d69",
"assets/assets/companions/segelkamm-epic.png": "3016f336e6a0bd66e24ce37fa897b64d",
"assets/assets/companions/valve.png": "b991d3c9327fe6ec68ccadcb3e1d6541",
"assets/assets/companions/vine-rare.png": "d6ab0c20c6ebf0263db940ad49684853",
"assets/assets/companions/schwammo_c.png": "1f59caf20221206d912c8697b5ba79a2",
"assets/assets/companions/dune.png": "cbc0ab0e395b977d5579f0147b0727d2",
"assets/assets/companions/teerbock-legendary.png": "3e62c99f85b5035e23df9bfa1258f830",
"assets/assets/companions/coil-epic.png": "4fbdd2312f0c255e09b95af66429325d",
"assets/assets/companions/nebulo.png": "85abf2a7f555e3f1e004489cb1833cad",
"assets/assets/companions/pebble.png": "32e394f6570576fa1886ff70cdd27f6b",
"assets/assets/companions/kraterix-legendary.png": "414443305234fe5ad0752b4944c27b4d",
"assets/assets/companions/coil_c.png": "a32dfc1d7dc56a37932ffe0255df3787",
"assets/assets/companions/messingor-legendary.png": "5f3e581f3830973e32372363e14d1096",
"assets/assets/companions/tangwell-epic.png": "59350388ac2513457bde966e238b96ff",
"assets/assets/companions/muschlo-rare.png": "1b82f31820d5ca7945edecd9ad4c72ce",
"assets/assets/companions/lapisor-epic.png": "7fc425b0a28c546ff211879207601190",
"assets/assets/companions/kraterix_c.png": "34aeeb8d968cf3110d42bf54d8116557",
"assets/assets/companions/farnix-epic.png": "e1bdc75642d97f801e6a61092d664db9",
"assets/assets/companions/muttrix.png": "0a42d232cd6822fe929d5e5447e6eba5",
"assets/assets/companions/lakrillo_c.png": "06801532ef257e141d0b0c56d6e84e55",
"assets/assets/companions/lapisor-legendary.png": "af7ce46e1a2b360906f2e96bb4e2a4da",
"assets/assets/companions/nebulo_c.png": "d4301ab78c09f355e0d7c54479a1c425",
"assets/assets/companions/dune_c.png": "4e12094bef43efdf3b1ed65824027632",
"assets/assets/companions/valve-legendary.png": "3a44edd9218edcfabd13f68173752462",
"assets/assets/companions/teerbock.png": "dcab6979a04b8f2e859e9f0d0f13a2d7",
"assets/assets/companions/drahtel-rare.png": "08ff894b7362693aaa19fb35e20c844b",
"assets/assets/companions/lakrillo-legendary.png": "43fbbe9518af5c31f4531fa99dace622",
"assets/assets/companions/valve-rare.png": "b0145df4de11be19486c0d0892c37c4f",
"assets/assets/companions/papyrix-rare.png": "bb7a6a5d1ea8cd1176ce3594bd41f164",
"assets/assets/companions/muttrix_c.png": "6a553cc66ae1bbc8345de4cf833f42be",
"assets/assets/companions/brine.png": "4d70fbf27d248424387aeba74e96efba",
"assets/assets/companions/emaillo.png": "df7a3d0c5ff22923e36cbd9f01e40d84",
"assets/assets/companions/glaze.png": "ce7a8bbd223e611caa4b249cc0404696",
"assets/assets/companions/messingor_c.png": "d9ef47f4f40a155a5efff5c13576b426",
"assets/assets/companions/hookfin-rare.png": "a560beeb01854e1a93e5232bac66e2bb",
"assets/assets/companions/gilt-legendary.png": "7e230e51987bbb041c52eee5cabda3ec",
"assets/assets/companions/tangwell-legendary.png": "7c30a70e10c5424c316f5426ad54b6a8",
"assets/assets/companions/ringelpanz.png": "c7a0763a7da6f421998824b9c5bba29e",
"assets/assets/companions/hookfin-legendary.png": "f87284cd79c59e56783d1cf89c27c21c",
"assets/assets/companions/farnix-legendary.png": "7ea25b7438e6af3d2a817a7c9f75e4b9",
"assets/assets/companions/nebulo-epic.png": "c8510ae2d4ad1c452261ceab3ef6c0ac",
"assets/assets/companions/tangwell-rare.png": "adf20c7760c059626b707a4732536d43",
"assets/assets/companions/coil-rare.png": "7d3e3ee6119c3e1ed33241faf458cd82",
"assets/assets/companions/messingor-rare.png": "612f1a211d83e4638167c0470bb832af",
"assets/assets/companions/schwammo.png": "56e141143615a472ed970f7898cc50c7",
"assets/assets/companions/schwammo-rare.png": "673d27365d0b5d11a48a419df3dd5655",
"assets/assets/companions/farnix_c.png": "6755bb92b46a1da95f64a81a003c9c39",
"assets/assets/companions/emaillo-epic.png": "67bbf829702008efaacf5f9b90c9dcd5",
"assets/assets/companions/muttrix-rare.png": "4cafa1e4618818e367c2bacea0b30a75",
"assets/assets/companions/muschlo_c.png": "991911902bbcab0857b708ca1f049355",
"assets/assets/companions/papyrix-epic.png": "6fcc2397308814f1d943ce75692e984d",
"assets/assets/companions/segelkamm.png": "e0b24cd73724675a5a84b8855b6938d3",
"assets/assets/companions/puderling-legendary.png": "e64e604579df44f88c1da1c0e2fd9e45",
"assets/assets/companions/ringelpanz-legendary.png": "3723b4bcbab2650cc53cc6fbb4ee7724",
"assets/assets/companions/coil.png": "7c972c41ad34650c033813039e6fd1ed",
"assets/assets/companions/teerbock-epic.png": "3777131737b6653cd8a7b4331e5667e4",
"assets/assets/companions/drahtel.png": "caaf3c89d37d6555f4ea7f2fc98157b9",
"assets/assets/companions/lakrillo.png": "1ceac00e9ac9049bd040f0e0aad4ea03",
"assets/assets/companions/zinnbuck-epic.png": "dc6558292c98c8a18379e3cd59983fbf",
"assets/assets/companions/nebulo-rare.png": "50586a9899b95c4f21ba41ead7615833",
"assets/assets/companions/valve-epic.png": "1ef6e478637b7a26f7622d82cb6403ed",
"assets/assets/companions/emaillo-legendary.png": "4e0b079ad76161a9a2368be7baa00b26",
"assets/assets/companions/karamello.png": "8b698148c282995ab03ed5b23e26acf9",
"assets/assets/companions/vine_c.png": "5fe49072761d1ed5045bee5e44f88abe",
"assets/assets/companions/puderling.png": "3719a281827ae3cf37f22be5faa64c23",
"assets/assets/companions/lapisor_c.png": "2fc546d6bdc9db1bde0c2ee70d596d9e",
"assets/assets/companions/brine-legendary.png": "da58b321a731a93a03aad686a0ba38de",
"assets/assets/companions/karamello-epic.png": "343fafa5883544aed93f199346f760ca",
"assets/assets/companions/coil-legendary.png": "72f9667d888921fcec4464b43c5a7341",
"assets/assets/companions/segelkamm_c.png": "2443e5761c73de1b9002f55de03f17fb",
"assets/assets/companions/hookfin.png": "65edbc4383e6dd19c0a59c574118af20",
"assets/assets/companions/gilt_l.png": "552d7baed95d5760fdb66852c16da80f",
"assets/assets/companions/lapisor-rare.png": "8acdfa748c679759612c4039a4819195",
"assets/assets/companions/zinnbuck-rare.png": "6e454217d6219f3e3d3df9d11193af94",
"assets/assets/companions/muttrix-legendary.png": "0f8600834e90dc54acacc805fccd3cbd",
"assets/assets/companions/zinnbuck_c.png": "fc5a30e4f4cdc931aeb251230a177183",
"assets/assets/brand/app_icon_1024.png": "0e284d1bf80c036158477bae59441556",
"assets/assets/wanderweg/trail_3.webp": "41f8b7edb70e7dd012b4ffd8be35e050",
"assets/assets/wanderweg/trail_1.webp": "faf16860362ded07951be0424866eb91",
"assets/assets/wanderweg/trail_2.webp": "4d0e14aba22a323f3567be94f37f8069",
"assets/assets/wanderweg/trail_4.webp": "ec974523ae2d406b2d860e28611254aa",
"assets/assets/fonts/Inter-Regular.ttf": "6aaeaedf3625018d1b36723021c05149",
"assets/assets/fonts/AlegreyaSC-Medium.ttf": "6d719659abae25b6a2f38555881ca2ac",
"assets/assets/fonts/Inter-Bold.ttf": "f8ea65e151ec452ee5c6fced210cbbc0",
"assets/assets/fonts/Metamorphous-Regular.ttf": "d7cddf8aa5cc33dbca70627ad2be62c8",
"assets/assets/fonts/Cinzel-SemiBold.ttf": "4d3e5a66636a1bc870546445d0c3ce75",
"assets/assets/fonts/AlegreyaSC-Bold.ttf": "7fd444e6c61beccd16d84412da0dd939",
"assets/assets/fonts/Cinzel-Bold.ttf": "eb1859e7e66bd29d3fd65bc10da960ca",
"assets/assets/fonts/BarlowSemiCondensed-Bold.ttf": "624b3674baa9e2b18a0dcdd16a5b7164",
"assets/assets/fonts/BarlowSemiCondensed-SemiBold.ttf": "167bd6dd8945690d3632655aef7632ab",
"assets/assets/fonts/Inter-SemiBold.ttf": "3fb01f55d74603ea16785c0899ad167c",
"assets/assets/items/salve_small.webp": "5d6afa1e2265b7177c0d30d1b8eb8e3d",
"assets/assets/items/salve_medium.webp": "0280b199e4dbdb00334f760210144ede",
"assets/assets/items/salve_large.webp": "676b8bd2de0915f68b498eafa427c9c3",
"assets/assets/icons/ui_stop.webp": "cd3dcd44422da3162b4317906d501979",
"assets/assets/icons/ui_play.webp": "36e48d70b451bf4cc4d850a158447f7a",
"assets/assets/icons/ui_export.webp": "8dbc9531a7f2927097d066823b615f95",
"assets/assets/icons/ui_breath.webp": "37252bbe54a6e0dafe2a4173c629d709",
"assets/assets/icons/ui_buy.webp": "83dd9aa3b691d09c0424299515a0fa9e",
"assets/assets/icons/glut.webp": "daa941037a48afec989fdcd0f522e388",
"assets/assets/icons/splitter.webp": "f6fb0fab494b03713e20696a56792c3e",
"assets/assets/icons/ui_sell.webp": "283793167c527e6dda97c927071fd9bd",
"assets/assets/icons/glut_small.webp": "d0e0a88cc731b60cb4fe10e56d6b548d",
"assets/assets/icons/ui_video.webp": "a77aba7c780ec936054887968ed53211",
"assets/assets/icons/ui_lock.webp": "ef5ce062c06a3e3512194136c5c05f82",
"assets/assets/icons/ui_coin.webp": "fed3809b2694e5bf27ff4199698dae15",
"assets/assets/icons/ui_delete.webp": "3da79f5e76feb8d14298a68db0ac1b2c",
"assets/assets/icons/ui_logbook.webp": "1914b98a954f2d357f30bc45bb471534",
"assets/assets/icons/ui_import.webp": "af0a34a7df9323304a15519032b77403",
"assets/assets/icons/splitter_small.webp": "36e44a5dc3750a858e73e7dd402d9727",
"assets/assets/icons/ui_waymark.webp": "4612fd5f97bea6a5785f0636b448079d",
"assets/assets/seals/seal_stride_l5.webp": "d6b43fc03e2ba964704baa957fb9ab13",
"assets/assets/seals/recipe_wanderstern_l4.webp": "4efb76ea48cd4356f6f3464498ad4003",
"assets/assets/seals/recipe_schutz_l4.webp": "e1e371fa59dc5889dfa6558ad86f5f69",
"assets/assets/seals/recipe_faehrte_l1.webp": "fbd954cf56ed08edeb99978f692cff65",
"assets/assets/seals/recipe_wanderstern_l2.webp": "4867b15b3a2d2e6c2b8e70095d1ff7f2",
"assets/assets/seals/recipe_spurenleser_l5.webp": "30f616e63c577e5821aabfc6f8e5e19e",
"assets/assets/seals/seal_grit_l4.webp": "98d4e5bda0e4458403e52c0d398041fd",
"assets/assets/seals/recipe_glutherz_l4.webp": "33fceced933159ac0b74aa7d4b2534fa",
"assets/assets/seals/recipe_schutz_l3.webp": "b45f95965352aeff59434d5a3c121dc3",
"assets/assets/seals/recipe_spurenleser_l1.webp": "987876cf1ff849f74ff3914cc20fdb65",
"assets/assets/seals/recipe_glutherz_l2.webp": "da49d2eaa713fa151ca656932a0e648a",
"assets/assets/seals/recipe_glutherz_l5.webp": "476aa6c948993c9d1d39b4296a0825f7",
"assets/assets/seals/recipe_wanderstern_l3.webp": "85d3bacbd976f183294c221cb9a3f908",
"assets/assets/seals/recipe_ausdauer_l5.webp": "00ffec2a237c8ca3f24922b6ed162d70",
"assets/assets/seals/recipe_faehrte_l4.webp": "ace028f9774cb0a1a854c9332f3aceb7",
"assets/assets/seals/seal_fortune_l4.webp": "bb1af7dc01b6a451524c8a485fc31029",
"assets/assets/seals/seal_fortune_l3.webp": "513309cff5de284236fbe51e64c93fb6",
"assets/assets/seals/recipe_wanderstern_l1.webp": "ae3c9ea32fc02349b383385ecf5e818b",
"assets/assets/seals/seal_grit_l1.webp": "e87c816f99838e7a2f3bd50214ea64f9",
"assets/assets/seals/recipe_spurenleser_l4.webp": "123670c3eb3badda695b5f66f1b2313f",
"assets/assets/seals/seal_grit_l3.webp": "3f4ebf6e5e3f7d90fc4b5f4fa7fca577",
"assets/assets/seals/recipe_faehrte_l2.webp": "d00972e8d60135016e5468b84b69c457",
"assets/assets/seals/seal_fortune_l1.webp": "38624b834b5cec62d7bcdcab287fb89a",
"assets/assets/seals/recipe_spurenleser_l3.webp": "362a0073852e22ff1654493efd3f640f",
"assets/assets/seals/recipe_ausdauer_l3.webp": "1c034e4233fa119514f8d62fbd24c54a",
"assets/assets/seals/recipe_ausdauer_l1.webp": "3d38151bd8dc731eecb4bbefbdf01b43",
"assets/assets/seals/seal_stride_l2.webp": "c75c6d7a1084c797cec3c862cb12aec5",
"assets/assets/seals/recipe_glutherz_l1.webp": "d0748f6ed597b94f6cad2f5b856b5a31",
"assets/assets/seals/recipe_ausdauer_l2.webp": "275af6bda00d28c63f742094443eab92",
"assets/assets/seals/recipe_faehrte_l3.webp": "171721f674237c1e713e7c3d45072c94",
"assets/assets/seals/seal_fortune_l5.webp": "b682124e0f959c03a3f4e5e7fa287fab",
"assets/assets/seals/seal_fortune_l2.webp": "8c8b40381fbcf7a13d9698f8a96425f8",
"assets/assets/seals/seal_grit_l2.webp": "7791d0e83fd22295ef2939c94cb7a6bd",
"assets/assets/seals/recipe_ausdauer_l4.webp": "274d403d2fe42a58973a1464d26a6c56",
"assets/assets/seals/seal_stride_l1.webp": "aae88677eaab4aa7ec3ef7ef5d156cdf",
"assets/assets/seals/seal_stride_l4.webp": "fef202ba52007b618d0a15fdfe505450",
"assets/assets/seals/recipe_spurenleser_l2.webp": "7463f88c70f147eb1dbebe8868935b4b",
"assets/assets/seals/seal_combo_l5.webp": "a059513f66fec6c9ffa658765eca9ac5",
"assets/assets/seals/seal_grit_l5.webp": "e6be890481ee64fb9486d88f4049c82e",
"assets/assets/seals/recipe_faehrte_l5.webp": "08cc64c0bf3f9bd5b5022c425ea9b7c4",
"assets/assets/seals/recipe_schutz_l2.webp": "c13db4c3bc051d076d87285aec55aa93",
"assets/assets/seals/recipe_schutz_l1.webp": "dc3373b86a073435a7a8d41a538dbb6d",
"assets/assets/seals/recipe_schutz_l5.webp": "6971c202b413e4c38da22674cd53d7ca",
"assets/assets/seals/recipe_wanderstern_l5.webp": "8d62c0ca41a772bd7ce0a04178f02ed2",
"assets/assets/seals/seal_combo_l3.webp": "d86d62b0c97e7b0549cad7b22b41b5e1",
"assets/assets/seals/recipe_glutherz_l3.webp": "b4a610c307eb026fb9e1ea7383b7dc64",
"assets/assets/seals/seal_stride_l3.webp": "bae347cb3e2394e364e9b2408462e528",
"assets/assets/nav/nav_start.webp": "448d7bf1d28f8fd6eaf1a1e2000172d7",
"assets/assets/nav/nav_schmiede.webp": "c6599132ff00a8da4058430336a2498f",
"assets/assets/nav/nav_einstellungen.webp": "4a64195b8f0dc52561aede215d57f9bc",
"assets/assets/nav/nav_regal.webp": "9c7be20e999bcecc490742eae3553298",
"assets/assets/nav/nav_markt.webp": "3f6784121fea5d2ae0ff638a85e9bb2b",
"assets/NOTICES": "b03c9ddf12f021a962dda3aadcfb3c62",
"assets/fonts/MaterialIcons-Regular.otf": "ed196e8b2a8857635e4c0f612519f761",
"assets/AssetManifest.bin.json": "918678065a51733002d1b42403e4ebca",
"assets/AssetManifest.json": "d4475f2330e6a1d655c876c86e2bfe67",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "29f834319aa8abc35571f69880c7dd38",
"index.html": "9fa0f964eaf46a7fd82a93482cffbc8b",
"/": "9fa0f964eaf46a7fd82a93482cffbc8b",
"icons/Icon-maskable-512.png": "25b35cfbefce94b9b2eaa86de599777b",
"icons/Icon-512.png": "25b35cfbefce94b9b2eaa86de599777b",
"icons/Icon-192.png": "2af23632ba49545c4fb17cb765fee143",
"icons/Icon-maskable-192.png": "2af23632ba49545c4fb17cb765fee143",
"main.dart.js": "074571bcae12fe18905686bc70c7775b",
"flutter.js": "888483df48293866f9f41d3d9274a779"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
