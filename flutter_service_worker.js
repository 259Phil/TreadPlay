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
"flutter_bootstrap.js": "23dd8e5e4c6c2dc37a7c104f7a31f877",
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
"assets/assets/forge/hammer.webp": "9931b273cdf394be90a2d345e46a3bdf",
"assets/assets/forge/icon_case.webp": "a91f5ebc469164af338fea33b4ef0185",
"assets/assets/forge/combine_wax.webp": "75e7df3298eec7e71d002c4474a47420",
"assets/assets/forge/combine_grimoire.webp": "22fa1466280cd65013a1653e63503067",
"assets/assets/forge/icon_ladder.webp": "e3172b47cfe1ce4b9ced818990efbdbf",
"assets/assets/forge/icon_fuse.webp": "a35e72f0eacf3a56c4da08b4e1bac11e",
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
"assets/assets/companions/dune-epic.png": "e4ea493dbd4e7a08cbb0ecf7cbf6912e",
"assets/assets/companions/brine_c.png": "061c9a297edaad66d5b5e1d0301f7951",
"assets/assets/companions/vine.png": "822f0f3f2c578b362a19960e135d9199",
"assets/assets/companions/pebble-legendary.png": "e77c15be3bbf71f8da9ebf667ca3421d",
"assets/assets/companions/pebble-rare.png": "7421c60f2a1e147d27177afaf8850757",
"assets/assets/companions/pebble_c.png": "1830bfc807987fcbef436d4c9611138e",
"assets/assets/companions/glaze-epic.png": "707bfa67c29de4a8525a73b6a675a2e8",
"assets/assets/companions/lumen-legendary.png": "21bc811db886aaffa67add9460cca45a",
"assets/assets/companions/gilt.png": "1abde43a1f989159e1f9f76ce7c3034a",
"assets/assets/companions/brine-rare.png": "56e30a0556ada74c198e5266ad8d1de5",
"assets/assets/companions/glaze-legendary.png": "79b77bd5f1af57c8fa4d698606d49f87",
"assets/assets/companions/gilt_c.png": "c5901461738c748e54a5a743f7b88822",
"assets/assets/companions/vine-epic.png": "4020f9640f766feb52ce02795c7d17eb",
"assets/assets/companions/lumen.png": "a37308c117cff571e926f1ee043a5b7c",
"assets/assets/companions/brine-epic.png": "799d5caa2d479a402021b9c31c54f98d",
"assets/assets/companions/glaze_c.png": "704005e7ba2f4c8d53b761f8397a9837",
"assets/assets/companions/pebble-epic.png": "a073407bb8f7e10b3efcac78b5f8e119",
"assets/assets/companions/dune-legendary.png": "a8ec7f89c83bb94d8bdae5c2d1094550",
"assets/assets/companions/lumen-epic.png": "1c93bc7b137e3eff0e91cad8be355b25",
"assets/assets/companions/lumen_c.png": "4118111051b292e75f2a3b2b011fbdfb",
"assets/assets/companions/lumen-rare.png": "9e6a9ed5f67b2fe5d5dbbc1c4007f57f",
"assets/assets/companions/hookfin_c.png": "e236827b1f29609cc1c579c2d0b97c03",
"assets/assets/companions/valve_c.png": "5b5f0648be55d0b55d23a630d04a1be0",
"assets/assets/companions/hookfin-epic.png": "59484d62f7cc6a9ddbf52acf8d8c8acb",
"assets/assets/companions/gilt-rare.png": "964d4623d64883382da9d0126f6e9af0",
"assets/assets/companions/dune-rare.png": "cdf3c8ff80bce3a4c35cf431c96caa55",
"assets/assets/companions/glaze-rare.png": "ec8df0b8eee1103628ce8aa330bb9f01",
"assets/assets/companions/gilt_r.png": "b58222ca6e816865d2b4861b71b90c8b",
"assets/assets/companions/vine-legendary.png": "563ffb1cbb63db37b7ced1d90266a383",
"assets/assets/companions/gilt-epic.png": "a64db5a58f9e73004aa536679c721d69",
"assets/assets/companions/valve.png": "b991d3c9327fe6ec68ccadcb3e1d6541",
"assets/assets/companions/vine-rare.png": "d6ab0c20c6ebf0263db940ad49684853",
"assets/assets/companions/dune.png": "cbc0ab0e395b977d5579f0147b0727d2",
"assets/assets/companions/coil-epic.png": "4fbdd2312f0c255e09b95af66429325d",
"assets/assets/companions/pebble.png": "32e394f6570576fa1886ff70cdd27f6b",
"assets/assets/companions/coil_c.png": "a32dfc1d7dc56a37932ffe0255df3787",
"assets/assets/companions/dune_c.png": "4e12094bef43efdf3b1ed65824027632",
"assets/assets/companions/valve-legendary.png": "3a44edd9218edcfabd13f68173752462",
"assets/assets/companions/valve-rare.png": "b0145df4de11be19486c0d0892c37c4f",
"assets/assets/companions/brine.png": "4d70fbf27d248424387aeba74e96efba",
"assets/assets/companions/glaze.png": "ce7a8bbd223e611caa4b249cc0404696",
"assets/assets/companions/hookfin-rare.png": "a560beeb01854e1a93e5232bac66e2bb",
"assets/assets/companions/gilt-legendary.png": "7e230e51987bbb041c52eee5cabda3ec",
"assets/assets/companions/hookfin-legendary.png": "f87284cd79c59e56783d1cf89c27c21c",
"assets/assets/companions/coil-rare.png": "7d3e3ee6119c3e1ed33241faf458cd82",
"assets/assets/companions/coil.png": "7c972c41ad34650c033813039e6fd1ed",
"assets/assets/companions/valve-epic.png": "1ef6e478637b7a26f7622d82cb6403ed",
"assets/assets/companions/vine_c.png": "5fe49072761d1ed5045bee5e44f88abe",
"assets/assets/companions/brine-legendary.png": "da58b321a731a93a03aad686a0ba38de",
"assets/assets/companions/coil-legendary.png": "72f9667d888921fcec4464b43c5a7341",
"assets/assets/companions/hookfin.png": "65edbc4383e6dd19c0a59c574118af20",
"assets/assets/companions/gilt_l.png": "552d7baed95d5760fdb66852c16da80f",
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
"assets/assets/seals/seal_grit_l4.webp": "98d4e5bda0e4458403e52c0d398041fd",
"assets/assets/seals/seal_fortune_l4.webp": "bb1af7dc01b6a451524c8a485fc31029",
"assets/assets/seals/seal_fortune_l3.webp": "513309cff5de284236fbe51e64c93fb6",
"assets/assets/seals/seal_grit_l1.webp": "e87c816f99838e7a2f3bd50214ea64f9",
"assets/assets/seals/seal_grit_l3.webp": "3f4ebf6e5e3f7d90fc4b5f4fa7fca577",
"assets/assets/seals/seal_fortune_l1.webp": "38624b834b5cec62d7bcdcab287fb89a",
"assets/assets/seals/seal_stride_l2.webp": "c75c6d7a1084c797cec3c862cb12aec5",
"assets/assets/seals/seal_fortune_l5.webp": "b682124e0f959c03a3f4e5e7fa287fab",
"assets/assets/seals/seal_fortune_l2.webp": "8c8b40381fbcf7a13d9698f8a96425f8",
"assets/assets/seals/seal_grit_l2.webp": "7791d0e83fd22295ef2939c94cb7a6bd",
"assets/assets/seals/seal_stride_l1.webp": "aae88677eaab4aa7ec3ef7ef5d156cdf",
"assets/assets/seals/seal_stride_l4.webp": "fef202ba52007b618d0a15fdfe505450",
"assets/assets/seals/seal_combo_l5.webp": "a059513f66fec6c9ffa658765eca9ac5",
"assets/assets/seals/seal_grit_l5.webp": "e6be890481ee64fb9486d88f4049c82e",
"assets/assets/seals/seal_combo_l3.webp": "d86d62b0c97e7b0549cad7b22b41b5e1",
"assets/assets/seals/seal_stride_l3.webp": "bae347cb3e2394e364e9b2408462e528",
"assets/assets/nav/nav_start.webp": "448d7bf1d28f8fd6eaf1a1e2000172d7",
"assets/assets/nav/nav_schmiede.webp": "c6599132ff00a8da4058430336a2498f",
"assets/assets/nav/nav_einstellungen.webp": "4a64195b8f0dc52561aede215d57f9bc",
"assets/assets/nav/nav_regal.webp": "9c7be20e999bcecc490742eae3553298",
"assets/assets/nav/nav_markt.webp": "3f6784121fea5d2ae0ff638a85e9bb2b",
"assets/NOTICES": "b03c9ddf12f021a962dda3aadcfb3c62",
"assets/fonts/MaterialIcons-Regular.otf": "1f97fe92533d02781679035384546e7f",
"assets/AssetManifest.bin.json": "2345bb9bb6b38743952521dd6a9d75c0",
"assets/AssetManifest.json": "a64dcdbf87975e3d5744e6643abbce5e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "a9d8e29b019059b8f7bdd3550a4e7d81",
"index.html": "9fa0f964eaf46a7fd82a93482cffbc8b",
"/": "9fa0f964eaf46a7fd82a93482cffbc8b",
"icons/Icon-maskable-512.png": "25b35cfbefce94b9b2eaa86de599777b",
"icons/Icon-512.png": "25b35cfbefce94b9b2eaa86de599777b",
"icons/Icon-192.png": "2af23632ba49545c4fb17cb765fee143",
"icons/Icon-maskable-192.png": "2af23632ba49545c4fb17cb765fee143",
"main.dart.js": "98d1db14675e6f00584d80c7eaf533d4",
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
