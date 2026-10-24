import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';

String unlockLabel(AppLocalizations l, WaymarkUnlock u) => switch (u) {
  WaymarkUnlock.brownPouch => l.wwUnlockBrownPouch,
  WaymarkUnlock.forge => l.wwUnlockForge,
  WaymarkUnlock.marketMedievalJungle => l.wwUnlockMarketMedievalJungle,
  WaymarkUnlock.copperPouch => l.wwUnlockCopperPouch,
  WaymarkUnlock.forgeL2 => l.wwUnlockForgeL2,
  WaymarkUnlock.worldUnderwater => l.wwUnlockWorldUnderwater,
  WaymarkUnlock.leashClip4 => l.wwUnlockLeashClip4,
  WaymarkUnlock.forgeL3 => l.wwUnlockForgeL3,
  WaymarkUnlock.marketEgyptPirate => l.wwUnlockMarketEgyptPirate,
  WaymarkUnlock.turquoisePouch => l.wwUnlockTurquoisePouch,
  WaymarkUnlock.worldSteampunk => l.wwUnlockWorldSteampunk,
  WaymarkUnlock.forgeL4 => l.wwUnlockForgeL4,
  WaymarkUnlock.combineL3 => l.wwUnlockCombineL3,
  WaymarkUnlock.navyPouch => l.wwUnlockNavyPouch,
  WaymarkUnlock.worldSpaceRobot => l.wwUnlockWorldSpaceRobot,
  WaymarkUnlock.forgeL5 => l.wwUnlockForgeL5,
  WaymarkUnlock.shelfPlus2 => l.wwUnlockShelfPlus2,
  WaymarkUnlock.combineL5 => l.wwUnlockCombineL5,
  WaymarkUnlock.worldRococoCandy => l.wwUnlockWorldRococoCandy,
};

String taskLabel(AppLocalizations l, WaymarkTask t) => switch (t.counter) {
  WaymarkCounter.brownPouchesOpened => l.wwTaskBrownPouch,
  WaymarkCounter.copperPouchesOpened => l.wwTaskCopperPouch,
  WaymarkCounter.turquoisePouchesOpened => l.wwTaskTurquoisePouch,
  WaymarkCounter.sealsPlaced => l.wwTaskSealPlaced,
  WaymarkCounter.sealsForged => l.wwTaskSealsForged(t.target),
  WaymarkCounter.bestSealLevel => l.wwTaskSealL3,
  WaymarkCounter.messengersMet => l.wwTaskMessenger,
  WaymarkCounter.sweetSpot58Runs => l.wwTaskSweet58,
  WaymarkCounter.sweetSpot71Runs => l.wwTaskSweet71(t.target),
  WaymarkCounter.pouchesOpened => l.wwTaskPouches(t.target),
  WaymarkCounter.leashFilled => l.wwTaskLeash,
  WaymarkCounter.companionsBought => l.wwTaskBuy,
  WaymarkCounter.companionLevel => l.wwTaskLevel(t.target),
  WaymarkCounter.combines => l.wwTaskCombine,
};

/// The mentor / messenger line of waymark [n] (1-based).
String waymarkLine(AppLocalizations l, int n) => switch (n) {
  1 => l.wwLine1,
  2 => l.wwLine2,
  3 => l.wwLine3,
  4 => l.wwLine4,
  5 => l.wwLine5,
  6 => l.wwLine6,
  7 => l.wwLine7,
  8 => l.wwLine8,
  9 => l.wwLine9,
  10 => l.wwLine10,
  11 => l.wwLine11,
  12 => l.wwLine12,
  13 => l.wwLine13,
  14 => l.wwLine14,
  15 => l.wwLine15,
  16 => l.wwLine16,
  17 => l.wwLine17,
  18 => l.wwLine18,
  _ => l.wwLine19,
};
