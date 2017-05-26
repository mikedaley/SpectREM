//
//  main.cpp
//  SmartCardServer
//
//  Created by mac user  on 25/05/2017.
//  Copyright © 2017 Paul Tankard. All rights reserved.
//

#include <iostream>
#define ASIO_STANDALONE
#import "asio.hpp"
using asio::ip::tcp;

struct _readPacket
{
	uint8_t _packetType, _packetData;
	uint16_t _packetAddress;
};

void session(tcp::socket sock)
{
	std::cout << "Connected" << std::endl;
	for (;;)
	{
		_readPacket _packet;
			
		asio::error_code ec;
		asio::read(sock, asio::buffer(&_packet, sizeof(_packet)), ec);
		if (ec) break;
		if(_packet._packetType == 1)
		{
			asio::write(sock, asio::buffer(&_packet, sizeof(_packet)), ec);
			if (ec) break;
			_packet._packetData = 0;
			printf("PortRead(%.4x) -> %.2x\n", _packet._packetAddress, _packet._packetData);
		}
		else if(_packet._packetType == 2)
		{
			printf("PortWrite(%.4x) <- %.2x\n", _packet._packetAddress, _packet._packetData);
		}
	}
}

void server(asio::io_context& io_context, unsigned short port)
{
	tcp::acceptor a(io_context, tcp::endpoint(asio::ip::address::from_string("127.0.0.1"), port));
	//tcp::acceptor a(io_context, tcp::endpoint(tcp::v4(), port));
	for (;;)
	{
		std::thread(session, a.accept()).detach();
	}
}

int main(int argc, const char * argv[]) {

	 asio::io_context io_context;
	 server(io_context, 5555);
	
	

	return 0;
}
