import std.stdio;
import std.socket;
import std.datetime;
import std.bitmanip;

// from reference
struct Packet {
    align(1):		  // we want the structure packed, with no gaps
	  byte flags=0x23;  // Flags 00|100|011 for li=0, vn=4, mode=3
    byte stratum;
    byte poll;
    byte precision;
    uint root_delay;
    uint root_dispersion;
    uint referenceID;
    uint ref_ts_secs;
    uint ref_ts_frac;
    uint origin_ts_secs;
    uint origin_ts_frac;
    ubyte[4] recv_ts_secs;  // This is what we need mostly to get current time.
    ubyte[4] recv_ts_fracs; // for this example nanoseconds can be dropped
    uint transmit_ts_secs;
    uint transmit_ts_frac;
}

const ntpEpochOffset = 2208988800L; // Difference between Jan 1, 1900 and Jan 1, 1970

void main()
{
    auto sock=new UdpSocket(AddressFamily.INET);
    Packet packet;  // stack allocation
    sock.connect(new InternetAddress("europe.pool.ntp.org",123));
    sock.send((&packet)[0..1]);
    sock.receive((&packet)[0..1]);
    sock.close();
	  auto unixTime=bigEndianToNative!uint(packet.recv_ts_secs); // network byte order is Big-Endian
    auto stdTime = SysTime.fromUnixTime(unixTime-ntpEpochOffset); // NTP returns seconds from Jan 1, 1900
    writeln("Hello, the time is: ",stdTime);
}
