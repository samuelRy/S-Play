#include "miniaudio.c"
#include "stdlib.h"
#include "stdio.h"
#include <windows.h>
#include <pthread.h>
#include "math.h"
#include "complex.h"
#include <stdatomic.h>
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
#define NUM_BANDS 7
typedef struct
{
    float b0, b1, b2;
    float a1, a2;
    float z1, z2;
} Biquad;
void fft(complex float output[], float signal[], int size, int step);
void applyEq(complex float *fftOut, float subBassGain, float bassGain, float lowMidrangeGain, float midrangeGain, float upperMidsGain, float highMidsGain, float trebleGain);
void ifft(complex float output[], complex float signal[], int size, int step);
void stopAudioThread(HANDLE *hThread);
static inline float biquad_process(Biquad *b, float x);
void biquad_peaking(Biquad *q, float fs, float f0, float Q, float gainDB);
HANDLE hThread = NULL;
volatile float framesRead;
_Atomic ma_bool32 running = false;
ma_bool32 eq = false;


Biquad beq[NUM_BANDS];
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
float subBassGain = 0, bassGain = 0, lowMidrangeGain = 0;
float midrangeGain = 0, upperMidsGain = 0;
float highMidsGain = 0;
float trebleGain = 0;
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
        ma_uint32 framesToReadNow = fftSize / pDecoder->outputChannels;
        if (framesToReadNow > totalFramesRemaining)
        {
            framesToReadNow = totalFramesRemaining;
        }
        // if (subBassGain!=0.0f)
        // {
        //     printf("%f\n", subBassGain);

        // }
        if (ma_decoder_read_pcm_frames(pDecoder, temp, framesToReadNow, &pFramesRead) != MA_SUCCESS)
        {
        }

        for (ma_uint64 i = 0; i < pFramesRead*pDecoder->outputChannels; i++)
        {
            float x = temp[i];

            for (int b = 0; b < NUM_BANDS; b++)
            {
                x = biquad_process(&beq[b], x);
            }

        // printf(" read\n");
            out[i] = x;
            // printf("%f %f %f %f\n", creal(output[sample]), cimag(output[sample]),creal(output[sample+((pFramesRead * pDecoder->outputChannels)/2)]), cimag(output[sample+((pFramesRead * pDecoder->outputChannels)/2)]));
        }

        // printf("%lu\n", (unsigned long)framesToReadNow);
    }

    const size_t sampleCount = (size_t)frameCount * (size_t)decoder.outputChannels;
    const size_t copyCount = min(fftSize, sampleCount);

    memset(frames, 0, sizeof(frames));
    memcpy(frames, pOutput, copyCount * sizeof(float));

    fftReady = true;

    (void)pInput;
}

static inline float biquad_process(Biquad *b, float x)
{
    float y = b->b0 * x + b->z1;
    b->z1 = b->b1 * x - b->a1 * y + b->z2;
    b->z2 = b->b2 * x - b->a2 * y;
    return y;
}

void biquad_peaking(Biquad *q, float fs, float f0, float Q, float gainDB)
{
    float A = powf(10.0f, gainDB / 40.0f);
    float w0 = 2.0f * M_PI * f0 / fs;
    float alpha = sinf(w0) / (2.0f * Q);

    float b0 = 1 + alpha * A;
    float b1 = -2 * cosf(w0);
    float b2 = 1 - alpha * A;
    float a0 = 1 + alpha / A;
    float a1 = -2 * cosf(w0);
    float a2 = 1 - alpha / A;

    q->b0 = b0 / a0;
    q->b1 = b1 / a0;
    q->b2 = b2 / a0;
    q->a1 = a1 / a0;
    q->a2 = a2 / a0;

    q->z1 = q->z2 = 0.0f;
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
    biquad_peaking(&beq[0], deviceConfig.sampleRate, 80, 1.0f, subBassGain);
    biquad_peaking(&beq[1], deviceConfig.sampleRate, 200, 1.0f, bassGain);
    biquad_peaking(&beq[2], deviceConfig.sampleRate, 500, 1.0f, lowMidrangeGain);
    biquad_peaking(&beq[3], deviceConfig.sampleRate, 1000, 1.0f, midrangeGain);
    biquad_peaking(&beq[4], deviceConfig.sampleRate, 3000, 1.0f, upperMidsGain);
    biquad_peaking(&beq[5], deviceConfig.sampleRate, 8000, 1.0f, highMidsGain);
    biquad_peaking(&beq[6], deviceConfig.sampleRate, 12000, 1.0f, trebleGain);

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
    biquad_peaking(&beq[0], deviceConfig.sampleRate, 80, 1.0f, subBassGain);
    biquad_peaking(&beq[1], deviceConfig.sampleRate, 200, 1.0f, bassGain);
    biquad_peaking(&beq[2], deviceConfig.sampleRate, 500, 1.0f, lowMidrangeGain);
    biquad_peaking(&beq[3], deviceConfig.sampleRate, 1000, 1.0f, midrangeGain);
    biquad_peaking(&beq[4], deviceConfig.sampleRate, 3000, 1.0f, upperMidsGain);
    biquad_peaking(&beq[5], deviceConfig.sampleRate, 8000, 1.0f, highMidsGain);
    biquad_peaking(&beq[6], deviceConfig.sampleRate, 12000, 1.0f, trebleGain);
}

void applyEq(complex float *fftOut, float subBassGain, float bassGain, float lowMidrangeGain,
             float midrangeGain, float upperMidsGain, float highMidsGain, float trebleGain)
{

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
            gain = bassGain;
        }
        else if (freq < 500.0f)
        {
            gain = lowMidrangeGain;
        }
        else if (freq < 2000.0f)
        {
            gain = midrangeGain;
        }
        else if (freq < 4000.0f)
        {
            gain = upperMidsGain;
        }
        else if (freq < 6000.0f)
        {
            gain = highMidsGain;
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
                // printf("i: %d  val: %f  freq: %f l: %d m: %d h: %d", i, val, freq, l, m, h);
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
            // printf("%d %f\n", h, high[h-1]);

            /*float signal[8];
            for (size_t i = 0; i < 8; i++)
            {
                // signal[i] = sinf(t*2*pi) + sinf(2*pi*t*3);
                signal[i] = sinf(2.0 * 1 * pi * (float)i / 8) + cosf(3.0 * 2 * pi * (float)i / 8);
            }
            fft(output, signal, 8, 1);*/
        }
        // Sleep(100);
    }
}

void fftThreadStop()
{
    fftRunning = false;
    pthread_join(fftThread, NULL);
}

void disposeSoundData()
{
    printf("Dispose started\n");
    running = false;
    // fflush(stdout);
    if (hThread != NULL)
    {
        printf("Stoping audio thread\n");
        stopAudioThread(&hThread);
        // fflush(stdout);
    }
    fftThreadStop();
    ma_device_stop(&device);
    ma_device_uninit(&device);
    ma_decoder_uninit(&decoder);
    printf("Dispose ended\n");
    // fflush(stdout);
}

/*void disposeGlobal()
{

}*/

void modifyVolume(float volume)
{
    if (volume >= 0.0f && volume <= 1.0f)
    {
// printf("volume: %f", volume);
        ma_device_set_master_volume(&device, volume);
        // Sleep(200);
    }
}

void seekFrames(ma_bool32 increase)
{
    ma_device_stop(&device);
    // Sleep(50);
    ma_decoder_get_cursor_in_pcm_frames(&decoder, &cursor);
    ma_uint64 secondsFrames = 10 * decoder.outputSampleRate;
    ma_uint64 frameTarget = increase ? ma_min(cursor + secondsFrames, length) : ma_max((ma_int64)cursor - (ma_int64)secondsFrames, 0);
    ma_decoder_seek_to_pcm_frame(&decoder, frameTarget);
    ma_device_start(&device);
    // Sleep(300);
}

void seekToFrames(int seconds)
{
    ma_device_stop(&device);
    // Sleep(50);
    ma_uint64 frameTarget = seconds * decoder.outputSampleRate;
    ma_decoder_seek_to_pcm_frame(&decoder, frameTarget);
    ma_device_start(&device);
    // Sleep(500);
}

void seekToEnd()
{
    ma_device_stop(&device);
    // Sleep(50);
    ma_decoder_get_length_in_pcm_frames(&decoder, &length);
    ma_decoder_seek_to_pcm_frame(&decoder, length - decoder.outputSampleRate);
    ma_device_start(&device);
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

        Sleep(100);
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