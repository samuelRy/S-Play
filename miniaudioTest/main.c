#include "miniaudio.c"
#include "stdlib.h"
#include <stdio.h>
#include "stdint.h"
#include <windows.h>
#include <time.h>

#include <conio.h>
#include "complex.h"
#define pi MA_PI
#define e ma_expd
#define true MA_TRUE
#define false MA_FALSE
#define forV(x) for (int x = 0; x < n; x++)
#define forVN(x, n) for (int x = 0; x < n; x++)
#define ARRAY_LEN(x) sizeof(x) / sizeof(x[0])
#define MIN(a, b) (a < b) ? a : b
#define MAX(a, b) (a > b) ? a : b
#define SPACE 32
#define ESCAPE 27
#define RIGHT 77
#define LEFT 75
#define UP 72
#define DOWN 80
#define fftSize 4096
#define BUFFER_RING_SIZE 2048
#define isSubBass(x) x < 60
#define isBass(x) x < 250
#define isLowMidrange(x) x < 500
#define isMidrange(x) x < 2000
#define isUpperMids(x) x < 4000
#define isHighMids(x) x < 6000
#define isTreble(x) x < 20000

ma_bool32 fftRunning = true;

// void fft(size_t sampleSize, float samples[], complex float outPut[], float amp[]);

float frames[fftSize];
float subBassGain = 1, bassGain = 1, lowNidrangeGain = 1, midrangeGain = 1, upperMidsGain = 1, highMidsGain = 1, trebleGain = 1;
void fft(complex float output[], float signal[], int size, int step);
void ifft(complex float output[], complex float signal[], int size, int step);
void applyEq(complex float *fftOut, float subBassGain, float bassGain, float lowMidrangeGain, float midrangeGain, float upperMidsGain, float highMidsGain, float trebleGain);
typedef struct
{
    float b0, b1, b2;
    float a1, a2;
    float z1, z2;
} Biquad;
static inline float biquad_process(Biquad *b, float x);
void biquad_peaking(Biquad *q, float fs, float f0, float Q, float gainDB);
Biquad beq[7];
void data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    ma_decoder *pDecoder = (ma_decoder *)pDevice->pUserData;
    if (pDecoder == NULL)
    {
        return;
    }
    ma_uint64 totalFramesRead = 0;
        float temp[fftSize];
        float *out = (float *)pOutput;
        /* code */

        ma_uint64 totalFramesRemaining = frameCount - totalFramesRead;
        ma_uint64 pFramesRead;
        ma_uint64 framesToReadNow = fftSize / pDecoder->outputChannels;
        if (framesToReadNow > totalFramesRemaining)
        {
            framesToReadNow = totalFramesRemaining;
            printf("%llu\n", (unsigned long long)frameCount);
        }
        if (ma_decoder_read_pcm_frames(pDecoder, temp, framesToReadNow, &pFramesRead) != MA_SUCCESS)
        {
            return;
        }

        for (ma_uint64 i = 0; i < pFramesRead*pDecoder->outputChannels; i++)
        {
            float x = temp[i];

            for (int b = 0; b < 7; b++)
            {
                x = biquad_process(&beq[b], x);
            }

        // printf(" read\n");
            out[i] = x;
            // printf("%f %f %f %f\n", creal(output[sample]), cimag(output[sample]),creal(output[sample+((pFramesRead * pDecoder->outputChannels)/2)]), cimag(output[sample+((pFramesRead * pDecoder->outputChannels)/2)]));
        }
totalFramesRead+=pFramesRead;
    // printf("framesCount: %d  FramesRead: %lu\n", frames, (unsigned long)pFramesRead);

    (void)pInput;
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


static inline float biquad_process(Biquad *b, float x)
{
    float y = b->b0 * x + b->z1;
    b->z1 = b->b1 * x - b->a1 * y + b->z2;
    b->z2 = b->b2 * x - b->a2 * y;
    return y;
}


int main()
{
    clock_t start, end;
    double cpu_time_used;
    start = clock();
    ma_result result;
    ma_decoder decoder;
    ma_device_config deviceConfig;
    ma_device device;
    result = ma_decoder_init_file("sound1.mp3", NULL, &decoder);
    if (result != MA_SUCCESS)
    {
        // string ch = "Failed to initialize " + filepath + "\n";

        printf("Failed to initialize file %s\n", "sound1.mp3");

        // fflush(stderr);
    }
    deviceConfig = ma_device_config_init(ma_device_type_playback);
    deviceConfig.playback.format = decoder.outputFormat;
    deviceConfig.playback.channels = decoder.outputChannels;
    deviceConfig.sampleRate = decoder.outputSampleRate;
    deviceConfig.dataCallback = data_callback;
    deviceConfig.pUserData = &decoder;
    
    biquad_peaking(&beq[0], deviceConfig.sampleRate, 80, 1.0f, 15.0f);
    biquad_peaking(&beq[1], deviceConfig.sampleRate, 200, 1.0f, 15.0f);
    biquad_peaking(&beq[2], deviceConfig.sampleRate, 500, 1.0f, 15.0f);
    biquad_peaking(&beq[3], deviceConfig.sampleRate, 1000, 1.0f, 15.0f);
    biquad_peaking(&beq[4], deviceConfig.sampleRate, 3000, 1.0f, 15.0f);
    biquad_peaking(&beq[5], deviceConfig.sampleRate, 8000, 1.0f, 15.0f);
    biquad_peaking(&beq[6], deviceConfig.sampleRate, 12000, 1.0f, 15.0f);
    if (ma_device_init(NULL, &deviceConfig, &device) != MA_SUCCESS)
    {
        printf("Failed to open playback device.\n");
        ma_decoder_uninit(&decoder);
        return -3;
    }
    if (ma_device_start(&device) != MA_SUCCESS)
    {
        printf("Failed to start playback device.\n");
        ma_device_uninit(&device);
        ma_decoder_uninit(&decoder);
        return -4;
    }
    printf("Press Enter to quit...\n");
    getchar();
    ma_device_uninit(&device);
    ma_decoder_uninit(&decoder);

    return 0;
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
        printf("%d  %f ", i, mean);
        mean /= step;
        opt[(int)(i / step)] = mean;
    }
}
void applyEq(complex float *fftOut, float subBassGain, float bassGain, float lowMidrangeGain, float midrangeGain, float upperMidsGain, float highMidsGain, float trebleGain)
{
    for (size_t i = 0; i < fftSize; i++)
    {

        ma_device device;
        ma_decoder decoder;
        // printf("freq: leur\n");
        float freq = (float)i * ((float) decoder.outputSampleRate / (float) fftSize);
        // printf("freq: %f\n", freq);
        if (isSubBass(freq))
        {
            fftOut[i] *= 2;
        }
        else if (isBass(freq))
        {
            fftOut[i] *= 1;
        }
        else if (isLowMidrange(freq))
        {
            fftOut[i] *= 1;
        }
        else if (isMidrange(freq))
        {
            fftOut[i] *= 1;
        }
        else if (isUpperMids(freq))
        {
            fftOut[i] *= 1;
        }
        else if (isHighMids(freq))
        {
            fftOut[i] *= 1;
        }
        else
        {
            fftOut[i] *= 3;
        }
    }
}