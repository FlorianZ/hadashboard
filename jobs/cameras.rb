require 'net/http'
 
@cameraDelay = 1 # Needed for image sync. 
@fetchNewImageEvery = '10s'

@camera1Host = "cctv_server"  ## CHANGE
@camera1Port = "80"  ## CHANGE
@camera1Username = 'None' ## CHANGE
@camera1Password = '' ## CHANGE
@camera1URL = "/mobile/channel01.jpg"
@newFile1 = "assets/images/cameras/snapshot1_new.jpeg"
@oldFile1 = "assets/images/cameras/snapshot1_old.jpeg"

@camera2Host = "cctv_server"  ## CHANGE
@camera2Port = "80"  ## CHANGE
@camera2Username = 'None' ## CHANGE
@camera2Password = '' ## CHANGE
@camera2URL = "/mobile/channel02.jpg"
@newFile2 = "assets/images/cameras/snapshot2_new.jpeg"
@oldFile2 = "assets/images/cameras/snapshot2_old.jpeg"

@camera3Host = "172.16.3.202"  ## CHANGE
@camera3Port = "80"  ## CHANGE
@camera3Username = 'xxxx' ## CHANGE
@camera3Password = 'xxxx' ## CHANGE
@camera3URL = "/Streaming/channels/1/picture"
@newFile3 = "assets/images/cameras/snapshot3_new.jpeg"
@oldFile3 = "assets/images/cameras/snapshot3_old.jpeg"

@camera4Host = "cctv_server"  ## CHANGE
@camera4Port = "80"  ## CHANGE
@camera4Username = 'None' ## CHANGE
@camera4Password = '' ## CHANGE
@camera4URL = "/mobile/channel03.jpg"
@newFile4 = "assets/images/cameras/snapshot4_new.jpeg"
@oldFile4 = "assets/images/cameras/snapshot4_old.jpeg"

@camera5Host = "cctv_server"  ## CHANGE
@camera5Port = "80"  ## CHANGE
@camera5Username = 'None' ## CHANGE
@camera5Password = '' ## CHANGE
@camera5URL = "/mobile/channel04.jpg"
@newFile5 = "assets/images/cameras/snapshot5_new.jpeg"
@oldFile5 = "assets/images/cameras/snapshot5_old.jpeg"

 
def fetch_image(host,old_file,new_file, cam_port, cam_user, cam_pass, cam_url)
	`rm #{old_file}` 
	`mv #{new_file} #{old_file}`	
	Net::HTTP.start(host,cam_port) do |http|
		req = Net::HTTP::Get.new(cam_url)
		if cam_user != "None" ## if username for any particular camera is set to 'None' then assume auth not required.
			req.basic_auth cam_user, cam_pass
		end
		response = http.request(req)
		open(new_file, "wb") do |file|
			file.write(response.body)
		end
	end
	new_file
end
 
def make_web_friendly(file)
  "/" + File.basename(File.dirname(file)) + "/" + File.basename(file)
end
 
SCHEDULER.every @fetchNewImageEvery, first_in: 0 do
	new_file1 = fetch_image(@camera1Host,@oldFile1,@newFile1,@camera1Port,@camera1Username,@camera1Password,@camera1URL)
	new_file2 = fetch_image(@camera2Host,@oldFile2,@newFile2,@camera2Port,@camera2Username,@camera2Password,@camera2URL)
	new_file3 = fetch_image(@camera3Host,@oldFile3,@newFile3,@camera3Port,@camera3Username,@camera3Password,@camera3URL)
	new_file4 = fetch_image(@camera4Host,@oldFile4,@newFile4,@camera4Port,@camera4Username,@camera4Password,@camera4URL)
	new_file5 = fetch_image(@camera5Host,@oldFile5,@newFile5,@camera5Port,@camera5Username,@camera5Password,@camera5URL)

	if not File.exists?(@newFile1 && @newFile2 && @newFile3)
		warn "Failed to Get Camera Images"
	end
 
	send_event('camera1', image: make_web_friendly(@oldFile1))
	send_event('camera2', image: make_web_friendly(@oldFile2))
	send_event('camera3', image: make_web_friendly(@oldFile3))
	send_event('camera4', image: make_web_friendly(@oldFile4))
	send_event('camera5', image: make_web_friendly(@oldFile5))
	sleep(@cameraDelay)
	send_event('camera1', image: make_web_friendly(new_file1))
	send_event('camera2', image: make_web_friendly(new_file2))
	send_event('camera3', image: make_web_friendly(new_file3))
	send_event('camera4', image: make_web_friendly(new_file4))
	send_event('camera5', image: make_web_friendly(new_file5))
	send_event('camTest', image: make_web_friendly(new_file5))
end
