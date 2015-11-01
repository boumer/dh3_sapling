#require 'digest'
#$digest_class = Digest::SHA256 #Used for internal digest creation. Change to use a different kind of hashing type. Everything goes, as long as it supports the .digest(string) method

class KademliaContact

	attr_reader  :identifier, :node_id, :ip, :port, :path,:last_contact_time, :times_connected

	def initialize(identifier, address, port, path:"/", contact_time: Time.now())
		@identifier = identifier.to_s
		@node_id = $digest_class.digest @identifier
		@address = address
		@port = port
		@path = path || "/"
		@last_contact_time = contact_time #used to sort contacts and see which ones are still functioning.
		@times_connected = 0
	end

	def client
		begin 
			yield KademliaClient.new(@address, @port, path: @path)

			#This line is only executed if the connection was successfull
			self.last_contact_time = Time.now
			self.times_connected += 1

		rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
       		puts "Connecting to `#{@address}:#{@port} -> #{@path}` threw the following error: #{e}"
       		raise Exceptions::KademliaClientConnectionError
   		end
	end

	def to_hash
		return {
			identifier: @identifier,
			node_id: @node_id,
			address: @address,
			port: @port,
			path: @path
		}
	end

	def self.from_hash(hash)
		puts hash
		#require 'json'
		#json = JSON.parse(raw_json, symbolize_names: true)
		KademliaContact.new(
				hash["identifier"],
				hash["address"],
				hash["port"],
				path: hash["path"]#,
				#json[:last_contact_time]
			)
	end

end