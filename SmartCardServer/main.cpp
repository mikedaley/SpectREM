//
//  main.cpp
//  SmartCardServer
//
//  Created by mac user  on 25/05/2017.
//  Copyright © 2017 Paul Tankard. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <chrono>
#define ASIO_STANDALONE
#import "asio.hpp"
using asio::ip::tcp;

struct _readPacket
{
    uint8_t _packetType, _packetData;
    uint16_t _packetAddress;
};

#define dbg_log(...)
//#define dbg_log printf


// Simulate the Maple SPI IRQ, which is what the spectrum will communicate with via hardware

enum { ZX_IDLE, ZX_RECEIVE_FROM_PC, ZX_SEND_TO_SPECTRUM, ZX_RECEIVE_FROM_SPECTRUM, ZX_SEND_TO_PC, ZX_ACK_TO_PC };
std::atomic_uint spectrumState(ZX_IDLE);
std::atomic_uint spectrumDataSize(0);
std::atomic_uint spectrumDataIndex(0);

uint8_t spectrumData[1024*10] = {0};

std::atomic_bool active(true);


void SendDataToSpectrum( uint8_t code, uint16_t location, uint16_t length, const void* data) {
    spectrumData[0] = code;
    spectrumData[1] = static_cast<uint8_t>(location);
    spectrumData[2] = static_cast<uint8_t>(location>>8);
    spectrumData[3] = static_cast<uint8_t>(length);
    spectrumData[4] = static_cast<uint8_t>(length>>8);
    memcpy(spectrumData + 5, data, length);
    spectrumDataIndex = 0;
    spectrumDataSize = length + 5;
    dbg_log("ZX_SEND_TO_SPECTRUM\n");
    spectrumState = ZX_SEND_TO_SPECTRUM;
}


void sender__()
{
    std::cout << "ready....." << std::endl;
    int state = 0;
    while(state!=9) {
        std::cin >> state;
        if(state==1) {
            std::ifstream snapshotFile("/Users/mikeda/Desktop/Roms/skooldaze.sna", std::ios::binary|std::ios::ate);
            std::vector<char> snapshotData(snapshotFile.tellg());
            snapshotFile.seekg(0, std::ios::beg);
            snapshotFile.read(snapshotData.data(), snapshotData.size());
            
            int snapshotIndex = 0;
            int spectrumAddress = 0x4000;
            
            // send register details.
            SendDataToSpectrum(0xa0, 0, 27, snapshotData.data());
            while(spectrumState!=ZX_ACK_TO_PC) {
                std::this_thread::sleep_for(std::chrono::milliseconds(2));
            }
            snapshotIndex += 27;
            
            const int blocksize = 8000;
            const int transferAmount = 48 * 1024;//
            // send game data.
            for (int block=0; block<transferAmount/blocksize; ++block) {
                SendDataToSpectrum(0xaa, spectrumAddress, blocksize, snapshotData.data() + snapshotIndex);
                while(spectrumState!=ZX_ACK_TO_PC) {
                    std::this_thread::sleep_for(std::chrono::milliseconds(2));
                }
                snapshotIndex += blocksize;
                spectrumAddress += blocksize;
            }
            if(transferAmount%blocksize) {
                SendDataToSpectrum(0xaa, spectrumAddress, transferAmount%blocksize, snapshotData.data() + snapshotIndex);
                while(spectrumState!=ZX_ACK_TO_PC) {
                    std::this_thread::sleep_for(std::chrono::milliseconds(2));
                }
            }
            // start game
            SendDataToSpectrum(0x80, 0, 0, snapshotData.data());
            while(spectrumState!=ZX_ACK_TO_PC) {
                std::this_thread::sleep_for(std::chrono::milliseconds(2));
            }
            
            state = 0;
        }
        
    }
    
    
    
    active = false;
}

void maple__main_loop()
{
    while (active) {
        if(spectrumState == ZX_ACK_TO_PC) {
            //Serial.write((char)0xaa);
            dbg_log("ZX_IDLE");
            spectrumState = ZX_IDLE;
        }
        else if(spectrumState == ZX_SEND_TO_PC) {
            //Serial.write((uint8*)keyPorts,10);
            dbg_log("ZX_IDLE");
            spectrumState = ZX_IDLE;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(2));
    }
}

void maple__irq_spi1(tcp::socket sock)
{
    std::cout << "Connected" << std::endl;
    
    _readPacket _packetIn;
    _readPacket _packetOut;
    asio::error_code ec;
    
    for (;;)
    {
        asio::read(sock, asio::buffer(&_packetIn, sizeof(_packetIn)), ec);
        if (ec) break;
        
        // spi_tx_reg(SPI.dev(), b);                       // echo data back to master
        if(_packetIn._packetType == 1)
        {
            asio::write(sock, asio::buffer(&_packetOut, sizeof(_packetOut)), ec);
            if (ec) break;
            if(spectrumState != ZX_IDLE) {
                //printf("PortRead(%.4x) -> %.2x\n", _packetOut._packetAddress, _packetOut._packetData);
            }
        }
        else {
            
            // short b = spi_rx_reg(SPI.dev());                // read data which shoould flush RXNE
            if(_packetIn._packetType == 2)
            {
                if(spectrumState != ZX_IDLE) {
                    //printf("PortWrite(%.4x) <- %.2x\n", _packetIn._packetAddress, _packetIn._packetData);
                }
            }
            
            if(spectrumState == ZX_IDLE && _packetIn._packetData == 0x88) {
                dbg_log("ZX_RECEIVE_FROM_SPECTRUM\n");
                spectrumData[0] = _packetIn._packetData;
                spectrumDataIndex = 1;
                spectrumState = ZX_RECEIVE_FROM_SPECTRUM;
            }
            else if(spectrumState == ZX_RECEIVE_FROM_SPECTRUM) {
                spectrumData[spectrumDataIndex++] = _packetIn._packetData;
                
                int a = spectrumDataIndex;
                int b = spectrumDataSize - 4;
                dbg_log("R* %.03d - %.03d [%.2x - %.2x]",a, b, spectrumData[spectrumDataIndex+3], _packetIn._packetData);
                
                if(spectrumData[spectrumDataIndex+3] != _packetIn._packetData) {
                    dbg_log(" Error");
                }
                dbg_log("\n");
                
                if(spectrumDataIndex>=spectrumDataSize-4) {
                    dbg_log("ZX_ACK_TO_PC\n");
                    spectrumState = ZX_ACK_TO_PC;
                    //uint32_t tmp = spectrumDataIndex;
                    //spectrumDataSize = tmp;
                    //spectrumDataIndex = 0;
                }
            }
            
            if(spectrumState == ZX_SEND_TO_SPECTRUM) {
                _packetOut._packetData = spectrumData[spectrumDataIndex++];
                int a = spectrumDataIndex;
                int b = spectrumDataSize;
                dbg_log("W* %.03d - %.03d [%.2x - %.2x]\n",a, b, spectrumData[spectrumDataIndex-1], _packetOut._packetData);
                
                if(spectrumDataIndex>=spectrumDataSize) {// && _packetOut._packetData==0x80) {
                    dbg_log("ZX_IDLE\n");
                    spectrumState = ZX_IDLE;
                }
            }
            
            if(spectrumState == ZX_SEND_TO_SPECTRUM && spectrumDataIndex>=spectrumDataSize) {
                //printf("ZX_ACK_TO_PC\n");
                //spectrumState = ZX_ACK_TO_PC;
                dbg_log("ZX_IDLE\n");
                spectrumState = ZX_IDLE;
            }
        }
    }
    std::cout << "Disonnected" << std::endl;
}

void server(asio::io_context& io_context, unsigned short port)
{
    tcp::acceptor a(io_context, tcp::endpoint(asio::ip::address::from_string("127.0.0.1"), port));
    //tcp::acceptor a(io_context, tcp::endpoint(tcp::v4(), port));
    
    std::thread(sender__).detach();
    //std::thread(maple__main_loop).detach();
    while (active) {
        std::thread(maple__irq_spi1, a.accept()).detach();
    }
}

int main(int argc, const char * argv[]) {
    
    asio::io_context io_context;
    server(io_context, 5555);
    
    
    
    return 0;
}

