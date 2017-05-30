//
//  Network.cpp
//  SpectREM
//
//  Created by Mike Daley on 30/05/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#define ASIO_STANDALONE
#import "asio.hpp"


class SLNetwork
{
public:
    SLNetwork() : _socket(_io_context), _resolver(_io_context) {}
    
    struct _readPacket
    {
        uint8_t _packetType, _packetData;
        uint16_t _packetAddress;
    };
    
    void connect()
    {
        asio::error_code ec;
        asio::connect(_socket, _resolver.resolve("127.0.0.1", "5555"), ec);
    }
    
    uint8_t read_port(uint16_t address)
    {
        _readPacket _packet{ 0x1, 0, address };
        asio::error_code ec;
        asio::write(_socket, asio::buffer(&_packet, sizeof(_packet)), ec);
        if(!ec)
        {
            asio::read(_socket, asio::buffer(&_packet, sizeof(_packet)), ec);
        }
        return _packet._packetData;
    }
    
    void write_port(uint16_t address, uint8_t data)
    {
        _readPacket _packet{ 0x2, data, address };
        asio::error_code ec;
        asio::write(_socket, asio::buffer(&_packet, sizeof(_packet)), ec);
    }
    
private:
    asio::io_context _io_context;
    asio::ip::tcp::socket _socket;
    asio::ip::tcp::resolver _resolver;
};
