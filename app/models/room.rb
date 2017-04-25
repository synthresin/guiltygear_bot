class Room < ApplicationRecord
  room_regex = /\A[a-z0-9]{4}\z/i

  validates :code, uniqueness: { message: '%{value}는 이미 존재하는 플매방 번호임.'},
                   presence: { message: '추가할 플매방 번호를 빼먹음. 예) 김길티 추가 39fh'},
                   format: {
                     with: room_regex,
                     message: "%{value}는 잘못된 방번호임. 4자리 숫자-알파벳 조합만 가능.",
                     allow_blank: true
                   }

  after_create :send_ifttt_create_event

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

  def send_ifttt_create_event
    uri = URI('https://maker.ifttt.com/trigger/kimguilty/with/key/cLP0WwfNfDmeybyi-BW0dM')
    Net::HTTP.post_form(uri, value1: '생성', value2: code)
  end
end
