import 'dart:ffi' as d_ffi;
import 'package:ffi/ffi.dart';

typedef InitializeSoundDataC = d_ffi.Int32 Function(d_ffi.Pointer<Utf16>);

typedef InitializeSoundDataDart = int Function(d_ffi.Pointer<Utf16>);

typedef InitializeGlobalC = d_ffi.Int32 Function();

typedef InitializeGlobalDart = int Function();

typedef DisposeSoundDataC = d_ffi.Void Function();

typedef DisposeSoundDataDart = void Function();

typedef StartPlayBackC = d_ffi.Int32 Function();

typedef StartPlayBackDart = int Function();

/*typedef TestC = d_ffi.Int32 Function(d_ffi.Pointer<Utf8>);

typedef TestDart = int Function(d_ffi.Pointer<Utf8>);*/

typedef PauseSoundC = d_ffi.Void Function(d_ffi.Bool);

typedef PauseSoundDart = void Function(bool);

typedef ModifyVolumeC = d_ffi.Void Function(d_ffi.Bool);

typedef ModifyVolumeDart = void Function(bool);

typedef SeekFramesC = d_ffi.Void Function(d_ffi.Bool);

typedef SeekFramesDart = void Function(bool);

typedef SeekToFramesC = d_ffi.Void Function(d_ffi.Int);

typedef SeekToFramesDart = void Function(int);

typedef SeekToEndC = d_ffi.Void Function();

typedef SeekToEndDart = void Function();

typedef GetElapsedTimeC = d_ffi.Int Function();

typedef GetElapsedTimeDart = int Function();

typedef ChangeEqC = d_ffi.Void Function();

typedef ChangeEqDart = void Function();

typedef ChangeGainsC = d_ffi.Void Function(d_ffi.Float subBassGainVal, d_ffi.Float bassGainVal, d_ffi.Float lowMidrangeGainVal, d_ffi.Float midrangeGainVal, d_ffi.Float upperMidsGainVal, d_ffi.Float highMidsGainVal, d_ffi.Float trebleGainVal);

typedef ChangeGainsDart = void Function(double subBassGainVal, double bassGainVal, double lowMidrangeGainVal, double midrangeGainVal, double upperMidsGainVal, double highMidsGainVal, double trebleGainVal);

List<bool> libInitialized = [false, false];
late final d_ffi.DynamicLibrary dyLib;

void loadLibrary() {
  if (!libInitialized.first) {
    try {
      dyLib = d_ffi.DynamicLibrary.open(
        r"D:/Code/S-Play/miniaudioTest/soundlib.dll",
      );
    } catch (e) {
      // print("Error: ${e.toString()}");

      // Check if file actually exists
      
      // print("File exists: ${exists.exists()}");
      rethrow;
    }
  }
  libInitialized[0] = true;
}

void initializeLibraryFunctions() {
  if (!libInitialized.last) {
    ampPtr = dyLib.lookup<d_ffi.Float>('amp');
    lowPtr = dyLib.lookup<d_ffi.Float>('low');
    midPtr = dyLib.lookup<d_ffi.Float>('mid');
    highPtr = dyLib.lookup<d_ffi.Float>('high');
    freqReadPtr = dyLib.lookup<d_ffi.Int>('freqRead');
    running = dyLib.lookup<d_ffi.Bool>('running');
    subBassGain = dyLib.lookup<d_ffi.Float>('subBassGain');
bassGain = dyLib.lookup<d_ffi.Float>('bassGain');
lowMidrangeGain = dyLib.lookup<d_ffi.Float>('lowMidrangeGain');
midrangeGain = dyLib.lookup<d_ffi.Float>('midrangeGain');
upperMidsGain = dyLib.lookup<d_ffi.Float>('upperMidsGain');
highMidsGain = dyLib.lookup<d_ffi.Float>('highMidsGain');
trebleGain = dyLib.lookup<d_ffi.Float>('trebleGain');
eq = dyLib.lookup<d_ffi.Bool>('trebleGain');
    initializeSoundData = dyLib
        .lookupFunction<InitializeSoundDataC, InitializeSoundDataDart>(
          "initializeSoundData",
        );
    
    disposeSoundData = dyLib
        .lookupFunction<DisposeSoundDataC, DisposeSoundDataDart>(
          "disposeSoundData",
        );
    
    startPlayBack = dyLib.lookupFunction<StartPlayBackC, StartPlayBackDart>(
      "startPlayback",
    );
    //test = dyLib.lookupFunction<TestC, TestDart>("test");
    pauseSound = dyLib.lookupFunction<PauseSoundC, PauseSoundDart>(
      "pauseSound",
    );
    modifyVolume = dyLib.lookupFunction<ModifyVolumeC, ModifyVolumeDart>(
      "modifyVolume",
    );
    seekFrames = dyLib.lookupFunction<SeekFramesC, SeekFramesDart>(
      "seekFrames",
    );
    seekToFrames = dyLib.lookupFunction<SeekToFramesC, SeekToFramesDart>(
      "seekToFrames",
    );
    seekToEnd = dyLib.lookupFunction<SeekToEndC, SeekToEndDart>(
      "seekToEnd",
    );
    getElapsedTime = dyLib.lookupFunction<GetElapsedTimeC, GetElapsedTimeDart>(
      "getElapsedTime",
    );
    changeEq = dyLib.lookupFunction<ChangeEqC, ChangeEqDart>(
      "changeEq",
    );
    changeGains = dyLib.lookupFunction<ChangeGainsC, ChangeGainsDart>(
      "changeGains",
    );
  }
  libInitialized[1] = true;
}

late final dynamic initializeSoundData;

late final dynamic disposeSoundData;

late final dynamic startPlayBack;
//late final dynamic test;
late final dynamic pauseSound;
late final dynamic modifyVolume;
late final dynamic seekFrames;
late final dynamic seekToFrames;
late final dynamic seekToEnd;
late final dynamic getElapsedTime;
late final dynamic changeEq;
late final dynamic changeGains;
late final d_ffi.Pointer<d_ffi.Float> ampPtr;
late final d_ffi.Pointer<d_ffi.Float> lowPtr;
late final d_ffi.Pointer<d_ffi.Float> midPtr;
late final d_ffi.Pointer<d_ffi.Float> highPtr;
late final d_ffi.Pointer<d_ffi.Int> freqReadPtr;
late final d_ffi.Pointer<d_ffi.Bool> running;
late final d_ffi.Pointer<d_ffi.Float> subBassGain;
late final d_ffi.Pointer<d_ffi.Float> bassGain;
late final d_ffi.Pointer<d_ffi.Float> lowMidrangeGain;
late final d_ffi.Pointer<d_ffi.Float> midrangeGain;
late final d_ffi.Pointer<d_ffi.Float> upperMidsGain;
late final d_ffi.Pointer<d_ffi.Float> highMidsGain;
late final d_ffi.Pointer<d_ffi.Float> trebleGain;
late final d_ffi.Pointer<d_ffi.Bool> eq;
// Call these functions in your main or initialization code:
// loadLibrary();
// initializeLibraryFunctions();
