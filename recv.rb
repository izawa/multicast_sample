require 'ipaddr'
require 'socket'

# multicast packet settings
MCAST_PORT = 44444
MCAST_ADDR = '224.0.0.100'

# The following table is from RFC 5771.
#
# Address Range                 Size       Designation
# -------------                 ----       -----------
# 224.0.0.0 - 224.0.0.255       (/24)      Local Network Control Block
# 224.0.1.0 - 224.0.1.255       (/24)      Internetwork Control Block
# 224.0.2.0 - 224.0.255.255     (65024)    AD-HOC Block I
# 224.1.0.0 - 224.1.255.255     (/16)      RESERVED
# 224.2.0.0 - 224.2.255.255     (/16)      SDP/SAP Block
# 224.3.0.0 - 224.4.255.255     (2 /16s)   AD-HOC Block II
# 224.5.0.0 - 224.255.255.255   (251 /16s) RESERVED
# 225.0.0.0 - 231.255.255.255   (7 /8s)    RESERVED
# 232.0.0.0 - 232.255.255.255   (/8)       Source-Specific Multicast Block
# 233.0.0.0 - 233.251.255.255   (16515072) GLOP Block
# 233.252.0.0 - 233.255.255.255 (/14)      AD-HOC Block III
# 234.0.0.0 - 238.255.255.255   (5 /8s)    RESERVED
# 239.0.0.0 - 239.255.255.255   (/8)       Administratively Scoped Block

udp = UDPSocket.new
udp.bind(Socket::INADDR_ANY, MCAST_PORT)

# Send multicast membership to all IPv4 interfaces.
Socket.getifaddrs.select{|x| x.addr.ipv4?}.each do |ifaddr|

  # If you use INADDR_ANY instead of ifaddr.addr.ip_address, 
  # System will choose one of interfaces automatically.
  mreq = IPAddr.new(MCAST_ADDR).hton + IPAddr.new(ifaddr.addr.ip_address).hton
  udp.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, mreq)

  # You can see with 'netstat -g' or 'ip maddr show' same info.
  puts "#{ifaddr.name}: #{ifaddr.addr.ip_address}"
end

loop do
  puts udp.recv(65535)
end

udp.close
