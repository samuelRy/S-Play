#include "miniaudio.c"
#include "stdlib.h"
#include "stdio.h"
#include <windows.h>
#include <pthread.h>
#include "math.h"
#include "complex.h"
#define pi MA_PI
#define e ma_expd
#define true MA_TRUE
#define false MA_FALSE
#define forV(x) for (int x = 0; x < n; x++)
#define forVN(x, n) for (int x = 0; x < n; x++)
/*#define ARRAY_LEN(x) sizeof(x) / sizeof(x[0])
#define MIN(a, b) (a < b) ? a : b
#define MAX(a, b) (a > b) ? a : b*/
#define SPACE 32
#define ESCAPE 27
#define RIGHT 77
#define LEFT 75
#define UP 72
#define DOWN 80
#define fftSize 4096
#define fftModSize 1024
#define BUFFER_RING_SIZE 2048
#define isSubBass(x) x < 60
#define isBass(x) x < 250
#define isLowMidrange(x) x < 500
#define isMidrange(x) x < 2000
#define isUpperMids(x) x < 4000
#define isHighMids(x) x < 6000
#define isTreble(x) x < 20000

void fft(complex float output[], float signal[], int size, int step);
void applyEq(complex float *fftOut, float subBassGain, float bassGain, float lowMidrangeGain, float midrangeGain, float upperMidsGain, float highMidsGain, float trebleGain);
void ifft(complex float output[], complex float signal[], int size, int step);
void stopAudioThread(HANDLE *hThread);
HANDLE hThread = NULL;
volatile float framesRead;
volatile ma_bool32 running = true;
ma_bool32 eq = false;

ma_bool32 fftRunning = false;
ma_bool32 fftReady = false;
pthread_t fftThread;
float frames[fftSize];
float amp[fftSize];
float ampOpt[fftSize / 16];
float low[fftSize / 16];
float mid[fftSize / 16];
float high[fftSize / 16];
int freqRead[3];
volatile float subBassGain = 1, bassGain = 1, lowMidrangeGain = 1;
volatile float midrangeGain = 1, upperMidsGain = 1;
volatile float highMidsGain = 1;
volatile float trebleGain = 1;
float ringBuffer[BUFFER_RING_SIZE];
complex float outBuffer[BUFFER_RING_SIZE];
int writePos = 0;
ma_result result;
ma_decoder decoder;
ma_device_config deviceConfig;
ma_device device;
ma_uint64 cursor;
ma_uint64 length;

void data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    fftReady = false;
    ma_decoder *pDecoder = (ma_decoder *)pDevice->pUserData;

    // printf("eq: %d", !eq);
    //    printf(" FrameCount:%u", frameCount);
    if (pDecoder == NULL)
    {
        return;
    }
    if (!eq)
    {
        ma_decoder_read_pcm_frames(pDecoder, pOutput, frameCount, NULL);
    }
    // In your data_callback, replace the entire EQ section with this:
    else
    {
        ma_uint64 totalFramesRead = 0;
        float temp[fftSize];
        float *out = (float *)pOutput;
        /* code */

        ma_uint32 totalFramesRemaining = frameCount - totalFramesRead;
        ma_uint64 pFramesRead;
        ma_uint32 framesToReadNow = fftModSize / pDecoder->outputChannels;
        if (framesToReadNow > totalFramesRemaining)
        {
            framesToReadNow = totalFramesRemaining;
        }
        // printf("%d\n", framesToReadNow);
        if (ma_decoder_read_pcm_frames(pDecoder, temp, framesToReadNow, &pFramesRead) != MA_SUCCESS)
        {
            // printf("Failed to read\n");
        }

        // printf("%lu\n", pFramesRead);
        // fflush(stdout);
        complex float output[fftModSize];
        fft(output, temp, fftModSize, 1);

        /* code */

        applyEq(output, subBassGain, bassGain, lowMidrangeGain, midrangeGain, upperMidsGain, highMidsGain, trebleGain);

        complex float modifiedSamples[fftModSize];
        ifft(modifiedSamples, output, fftModSize, 1);
        for (size_t i = 0; i < fftModSize; i++)
        {
            modifiedSamples[i] /= fftModSize;
            // printf("%f\n", crealf(modifiedSamples[i]));
        }

        // printf("%lu\n", (unsigned long)framesToReadNow);
        for (ma_uint64 sample = 0; sample < pFramesRead * pDecoder->outputChannels; sample++)
        {
            out[sample] = creal(modifiedSamples[sample]);
            // printf("%f %f %f %f\n", creal(output[sample]), cimag(output[sample]),creal(output[sample+((pFramesRead * pDecoder->outputChannels)/2)]), cimag(output[sample+((pFramesRead * pDecoder->outputChannels)/2)]));
        }
    }
    
    memcpy(frames, pOutput, fftSize * sizeof(float));

    fftReady = true;

    (void)pInput;
}

int initializeSoundData(const wchar_t *filepath)
{
    SetConsoleOutputCP(CP_UTF8);
    // printf("manbro\n");
    // fflush(stdout);

    result = ma_decoder_init_file_w(filepath, NULL, &decoder);
    if (result != MA_SUCCESS)
    {
        // string ch = "Failed to initialize " + filepath + "\n";

        wprintf(L"Failed to initialize file %ls %zu\n", filepath, wcslen(filepath));

        // fflush(stdout);

        // fflush(stderr);
        return -1;
    }
    deviceConfig = ma_device_config_init(ma_device_type_playback);
    deviceConfig.playback.format = decoder.outputFormat;
    deviceConfig.playback.channels = decoder.outputChannels;
    deviceConfig.sampleRate = decoder.outputSampleRate;
    deviceConfig.dataCallback = data_callback;
    deviceConfig.pUserData = &decoder;

    // printf("format %d\n", decoder.outputFormat);
    // fflush(stdout);
    return 1;
}

void optimizeAmp(float opt[], float amp[], size_t size, size_t oSize)
{
    size_t step = size / oSize;
    for (size_t i = 0; i < size; i += step)
    {
        float mean = 0;
        for (size_t j = 0; j < step; j++)
        {
            mean += amp[i + j];
        }

        mean /= step;
        opt[(int)(i / step)] = mean;
    }
}

void changeEq()
{
    eq = !eq;
}

void changeGains(float subBassGainVal, float bassGainVal, float lowMidrangeGainVal, float midrangeGainVal, float upperMidsGainVal, float highMidsGainVal, float trebleGainVal)
{
    subBassGain = subBassGainVal;
    bassGain = bassGainVal;
    lowMidrangeGain = lowMidrangeGainVal;
    midrangeGain = midrangeGainVal;
    upperMidsGain = upperMidsGainVal;
    highMidsGain = highMidsGainVal;
    trebleGain = trebleGainVal;
}

void applyEq(complex float *fftOut, float subBassGain, float bassGain, float lowMidrangeGain,
             float midrangeGain, float upperMidsGain, float highMidsGain, float trebleGain)
{
    float transitionWidth = 50.0f; // Hz transition width

    for (size_t i = 0; i < fftModSize; i++)
    {
        float freq = (float)i * ((float)decoder.outputSampleRate / (float)fftSize);
        float gain = 1.0f;

        // Smooth transitions between bands
        if (freq < 60.0f)
        {
            gain = subBassGain;
        }
        else if (freq < 250.0f)
        {
            float t = (freq - 60.0f) / (250.0f - 60.0f);
            gain = subBassGain * (1.0f - t) + bassGain * t;
        }
        else if (freq < 500.0f)
        {
            float t = (freq - 250.0f) / (500.0f - 250.0f);
            gain = bassGain * (1.0f - t) + lowMidrangeGain * t;
        }
        else if (freq < 2000.0f)
        {
            float t = (freq - 500.0f) / (2000.0f - 500.0f);
            gain = lowMidrangeGain * (1.0f - t) + midrangeGain * t;
        }
        else if (freq < 4000.0f)
        {
            float t = (freq - 2000.0f) / (4000.0f - 2000.0f);
            gain = midrangeGain * (1.0f - t) + upperMidsGain * t;
        }
        else if (freq < 6000.0f)
        {
            float t = (freq - 4000.0f) / (6000.0f - 4000.0f);
            gain = upperMidsGain * (1.0f - t) + highMidsGain * t;
        }
        else
        {
            gain = trebleGain;
        }

        // Apply gain with some limiting to prevent extreme values
        gain = fmaxf(0.1f, fminf(gain, 4.0f));
        fftOut[i] *= gain;
    }
}

void *fftThreadStart(void *arg)
{
    while (fftRunning)
    {
        if (fftReady)
        {
            complex float fl[fftSize];
            fft(fl, frames, fftSize, 1);

            size_t st = ma_countof(fl);
            for (size_t i = 0; i < st / 2; i++)
            {
                float re_i = creal(fl[i]);
                float im_i = cimag(fl[i]);
                amp[i] = sqrt((re_i * re_i) + (im_i * im_i));

                float re_s2_i = creal(fl[i + st / 2]);
                float im_s2_i = cimag(fl[i + st / 2]);
                amp[i + st / 2] = sqrt((re_s2_i * re_s2_i) + (im_s2_i * im_s2_i));
            }

            optimizeAmp(ampOpt, amp, fftSize, fftSize / 16);
            int l = 0, m = 0, h = 0;
            for (size_t i = 0; i < (fftSize / 16); i++)
            {
                float freq = (float)(i / 8.0f) * (0.5f * decoder.outputSampleRate / (fftSize / 16));
                float val;
                if (i > 2 && i < ((fftSize / 16) - 1))
                {
                    val = (ampOpt[i - 3] + ampOpt[i - 2] + ampOpt[i - 1] + ampOpt[i] + ampOpt[i + 1] + ampOpt[i + 2] + ampOpt[i + 3]) / 7.0f;
                    val = ampOpt[i];
                }
                else
                {
                    val = ampOpt[i];
                }
                // printf("i: %d  val: %f  freq: %f\n", i, val, freq);
                if (freq < 300.0f)
                {
                    low[l++] = val;
                }
                else if (freq < 2000.0f)
                {
                    mid[m++] = val;
                }
                else
                {
                    high[h++] = val;
                }
            }
            l--;
            m--;
            h--;
            freqRead[0] = l;
            freqRead[1] = m;
            freqRead[2] = h;

            /*float signal[8];
            for (size_t i = 0; i < 8; i++)
            {
                // signal[i] = sinf(t*2*pi) + sinf(2*pi*t*3);
                signal[i] = sinf(2.0 * 1 * pi * (float)i / 8) + cosf(3.0 * 2 * pi * (float)i / 8);
            }
            fft(output, signal, 8, 1);*/
        }
        Sleep(100);
    }
}

void fftThreadStop()
{
    fftRunning = false;
    pthread_join(fftThread, NULL);
}

void disposeSoundData()
{
    running = false;
    // printf("Dispose started\n");
    // fflush(stdout);
    if (hThread != NULL)
    {
        // printf("Stoping audio thread\n");
        stopAudioThread(&hThread);
        // fflush(stdout);
    }
    fftThreadStop();
    ma_device_stop(&device);
    ma_device_uninit(&device);
    ma_decoder_uninit(&decoder);
    // printf("Dispose ended\n");
    // fflush(stdout);
}

/*void disposeGlobal()
{

}*/

void modifyVolume(ma_bool32 increase)
{
    float volume;
    ma_device_get_master_volume(&device, &volume);
    volume += increase ? 0.1 : -0.1;
    if (volume >= 0.0f && volume <= 1.0f)
    {

        ma_device_set_master_volume(&device, volume);
        Sleep(200);
    }
}

void seekFrames(ma_bool32 increase)
{
    ma_device_stop(&device);
    Sleep(50);
    ma_decoder_get_cursor_in_pcm_frames(&decoder, &cursor);
    ma_uint64 secondsFrames = 10 * decoder.outputSampleRate;
    ma_uint64 frameTarget = increase ? ma_min(cursor + secondsFrames, length) : ma_max((ma_int64)cursor - (ma_int64)secondsFrames, 0);
    ma_decoder_seek_to_pcm_frame(&decoder, frameTarget);
    ma_device_start(&device);
    Sleep(300);
}

void seekToFrames(int seconds)
{
    ma_device_stop(&device);
    Sleep(50);
    ma_uint64 frameTarget = seconds * decoder.outputSampleRate;
    ma_decoder_seek_to_pcm_frame(&decoder, frameTarget);
    ma_device_start(&device);
    Sleep(500);
}

void seekToEnd()
{
    ma_device_stop(&device);
    Sleep(50);
    ma_decoder_get_length_in_pcm_frames(&decoder, &length);
    ma_decoder_seek_to_pcm_frame(&decoder, length);
    ma_device_start(&device);
    Sleep(100);
}

void pauseSound(ma_bool32 notPlaying)
{
    notPlaying ? ma_device_start(&device) : ma_device_stop(&device);
}

DWORD WINAPI playAudioThread(LPVOID param)
{
    // printf("running:%d\n", running);
    // printf("fft start");
    // fflush(stdout);

    fftRunning = true;
    pthread_create(&fftThread, NULL, fftThreadStart, NULL);
    while (running)
    {
        ma_decoder_get_cursor_in_pcm_frames(&decoder, &cursor);
        running = cursor < length;
        // printf("%u %u %d ", cursor, length, running);
        // printf("Hellofffplay\n");
        // fflush(stdout);

        Sleep(500);
    }
    if (!running)
    {
        // printf("ended%d\n", running);
        // fflush(stdout);
        return 5;
    }
    return 0;
}

void stopAudioThread(HANDLE *hThread)
{

    if (hThread != NULL)
    {
        WaitForSingleObject(*hThread, INFINITE);
        CloseHandle(*hThread);
        *hThread = NULL;
        // printf("everything done\n");
        // fflush(stdout);
    }
}

int getElapsedTime()
{
    ma_uint64 time = ma_decoder_get_cursor_in_pcm_frames(&decoder, &cursor);
    time = cursor / decoder.outputSampleRate;
    // printf("Elapsed time: %llu\n", (unsigned long long) time);
    return time;
}

int startPlayback()
{
    running = true;
    // fflush(stderr);
    if (ma_device_is_started(&device))
    {
        // printf("Another device playing\nShuting down the playing sound...\n");
        disposeSoundData();
        // printf("Sound dispsed of...\n");
        // fflush(stdout);
    }
    // OutputDebugStringA("Hello from C DLL\n");
    if (ma_device_init(NULL, &deviceConfig, &device) != MA_SUCCESS)
    {
        //    printf("Failed to initialize the playback device\n");
        // fflush(stdout);
        return -2;
    }

    ma_decoder_get_length_in_pcm_frames(&decoder, &length);

    if (ma_device_start(&device) != MA_SUCCESS)
    {
        // printf("Failed to start the playback device\n");
        // fflush(stdout);
        return -3;
    }

    // Sleep(1000);

    hThread = CreateThread(NULL, 0, playAudioThread, NULL, 0, NULL);
}

void fft(complex float output[], float signal[], int size, int step)
{
    // printf("Fourrier\n");
    if (size == 1)
    {
        output[0] = signal[0];
        return;
    }
    fft(output, signal, size / 2, step * 2);
    fft(output + size / 2, signal + step, size / 2, step * 2);

    for (size_t i = 0; i < size / 2; i++)
    {
        complex float t = output[i + size / 2] * cexpf(-2.0f * pi * I * (float)i / size);
        complex float out = output[i];
        output[i] = out + t;
        output[i + size / 2] = out - t;
    }
}

void ifft(complex float output[], complex float signal[], int size, int step)
{
    if (size == 1)
    {
        output[0] = signal[0];
        return;
    }
    ifft(output, signal, size / 2, step * 2);
    ifft(output + size / 2, signal + step, size / 2, step * 2);

    for (size_t i = 0; i < size / 2; i++)
    {
        complex float t = output[i + size / 2] * cexpf(2.0f * pi * I * (float)i / size);
        complex float out = output[i];
        output[i] = out + t;
        output[i + size / 2] = out - t;
    }
}