class Room < ApplicationRecord
  room_regex = /\A[a-z0-9]{4}\z/i

  validates :code, uniqueness: { message: '%{value}는 이미 존재하는 플매방 번호임.'},
                   presence: { message: '추가할 플매방 번호를 빼먹음. 예) 김길티 추가 39fh'},
                   format: {
                     with: room_regex,
                     message: "%{value}는 잘못된 방번호임. 4자리 숫자-알파벳 조합만 가능.",
                     allow_blank: true
                   }

  after_create :send_create_notification

  def bot_error_message
    errors.map { |attr, msg| msg }.join(" ")
  end

  def self.list_message
    return "현재 플매방 없음" if Room.count == 0

    room_infos = Room.all.map do |room|
      "*#{room.code}*        #{room.created_at.strftime('%m/%d %H:%M')} 생성"
    end

    room_infos.inject("*현재 플매방 목록*") do |full_message, room_info|
      full_message + "\n#{room_info}"
    end
  end

  def send_create_notification
    uri = URI.parse("https://fcm.googleapis.com/fcm/send")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "key=AAAAWFRfwG8:APA91bEHnyrH92YH6VMudWhNl4aZ6qnJ6Op-THYMqnmAAAP1o6g7-lb1tXI8q8YexzGGujQjmVJcYf8s309PVwcH-mP8vyFDEeoLu20FEbaXbcoIacOB-HyvpYw_mDF9rzxP_8Q-4Gdp"
    request.body = JSON.dump({
      "to" => "/topics/kimguilty",
      "data" => {
        "message" => "플매방 #{code} 생성됨",
        "timestamp" => Time.now.to_i
      }
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
