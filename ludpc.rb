# to build launch 'rake build:windows:folder'

require 'socket'
require 'timeout'
require 'net/http'
require 'uri'

module UDPClient
  LAMP_UDP_PORT = 12345

  def self.broadcast_to_potential_servers(content, udp_port)
    body = {:reply_port => LAMP_UDP_PORT, :content => content}

    s = UDPSocket.new
    s.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    s.send(Marshal.dump(body), 0, '<broadcast>', udp_port)
    s.close
  end

  def self.start_server_listener(time_out=3, &code)
    Thread.fork do
      s = UDPSocket.new
      s.bind('0.0.0.0', LAMP_UDP_PORT)

      begin
        body, sender = timeout(time_out) { s.recvfrom(1024) }
        server_ip = sender[3]
        data = Marshal.load(body)
        code.call(data, server_ip)
        s.close
      rescue Timeout::Error
        s.close
        raise
      end
    end
  end

  def self.query_server(content, server_udp_port, time_out=3, &code)
    thread = start_server_listener(time_out) do |data, server_ip|
      code.call(data, server_ip)
    end

    broadcast_to_potential_servers(content, server_udp_port)

    begin
      thread.join
    rescue Timeout::Error
      return false
    end

    true
  end

end

class LampUdpClient
  LAMP_SERVER_PORT = 1234

  attr_accessor :pi_ip
  
  def switch_lamp!

    response = false

    begin

      #puts "Querying http server..."
      uri = URI.parse("http://#{pi_ip}:4567/lamp/win")

      response = Timeout::timeout(3) do
        http = Net::HTTP.new(uri.host, uri.port)
        http.request(Net::HTTP::Get.new(uri.request_uri))
      end

    rescue Exception => ex
      #puts "Error switch_lamp!: #{ex.message()}"
      response = false
    end

    return response
  end

  def ping_server!
    #puts "Querying UDP server..."

    udp_ok = UDPClient.query_server("Hello", LAMP_SERVER_PORT) do |data, server_ip|
      #puts "Server answered:"
      #p(server_ip: server_ip, server_answer: data)
      self.pi_ip = server_ip
    end

    if udp_ok
      if switch_lamp!
        exit(0)
      else
        exit(2) # no http connection
      end
    else
      exit(1) # no udp connection
    end

  end

end

LampUdpClient.new.ping_server!