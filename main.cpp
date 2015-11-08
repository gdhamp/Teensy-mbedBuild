// Playback example with the USBAUDIO library

#include "mbed.h"
#include "USBAudio.h"
#include "USBSerial.h"

// frequency: 48 kHz
#define FREQ_SPK 16000
#define FREQ_MIC 16000

// 2channels: stereo
#define NB_CHA_SPK 2
#define NB_CHA_MIC 2

// length computed: each ms, we receive 48 * 16bits ->48 * 2 bytes. as there are two channels, the length will be 48 * 2 * 2
#define LENGTH_AUDIO_PACKET_SPK (FREQ_SPK / 500) * NB_CHA_SPK
#define LENGTH_AUDIO_PACKET_MIC (FREQ_MIC / 500) * NB_CHA_MIC

// USBAudio object
USBAudio audio(FREQ_SPK, NB_CHA_SPK, FREQ_MIC, NB_CHA_MIC, 0xab45, 0x0378);

int main() {
    // buffer of int
//    int buf_in[LENGTH_AUDIO_PACKET_SPK/sizeof(int)];
//    int buf_out[LENGTH_AUDIO_PACKET_MIC/sizeof(int)];
	int bufLen = LENGTH_AUDIO_PACKET_MIC/sizeof(int);
	int numBufs = 16;
    int buf[bufLen*numBufs];
    int* stream_out;
    int* stream_in;
	int i;

	memset(buf, 0, sizeof(buf));
	for (i=0; i<sizeof(buf)/sizeof(int); i++)
		buf[i] = i;
	i = 0;
    while (1) {
//		stream_in = &buf[i * bufLen];
//		stream_out = &buf[((i+(numBufs/2))%numBufs) * bufLen];
        // read and write one audio packet each frame
//       audio.readWrite((uint8_t *)stream_in, (uint8_t *)stream_out);
        
	for (i=0; i<sizeof(buf)/sizeof(int); i++)
		buf[i] = i;
		stream_out = &buf[i * bufLen];
       audio.write((uint8_t *)stream_out);
		i = (i+1)%numBufs;
    }
}


