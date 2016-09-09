require 'telegram/bot'

class KimguiltyController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    token = Rails.env.production? ? '257493779:AAEWFMdfDhlnK8isYU0NdrTtq14N8SnXask' : '239356367:AAEvlpyaxnrP9nZKm5U7OXn1MpGR2DbFukY'

    room_regex = /\A[a-z0-9]{4}\z/i
    redis = Redis.new(host: 'localhost', port: 6379)

    text = params[:message][:text]
    chat_id = params[:message][:chat][:id]
    args = text.split

    return head :ok, content_type: "text/html" unless args[0] == "김길티" || args[0] == "김길티!"

    command = args[1]
    rooms = redis.lrange('guiltygear:rooms', 0, -1)

    Telegram::Bot::Client.run(token) do |bot|
      case command
      when '추가'
        room_number = args[2]

        if room_number == nil
          bot.api.send_message(chat_id: chat_id, text: "추가할 플매방 번호를 빼먹음. 예) 김길티 추가 39fh")
        elsif room_regex.match(room_number)
          if rooms.include?(room_number)
            bot.api.send_message(chat_id: chat_id, text: "#{room_number}는 이미 있는 플매방 번호임")
          else
            redis.lpush("guiltygear:rooms", room_number)
            bot.api.send_message(chat_id: chat_id, text: "#{room_number} 플매방 추가 성공!\n현재 플매방 목록 : #{redis.lrange('guiltygear:rooms', 0, -1).join(' ')}")
            # TODO : rooms 목록을 가지고 공지를 새로 작성
          end
        else
          bot.api.send_message(chat_id: chat_id, text: "#{room_number}는 잘못된 방번호임. 4자리 숫자-알파벳 조합만 가능.")
        end

      when '삭제'
        room_number = args[2]

        if room_number == nil
          bot.api.send_message(chat_id: chat_id, text: "삭제할 플매방 번호를 빼먹음. 예) 김길티 삭제 39fh")
          next
        end

        if rooms.include?(room_number)
          redis.lrem("guiltygear:rooms", 0, room_number)
          bot.api.send_message(chat_id: chat_id, text: "#{room_number} 플매방 삭제 성공!\n현재 플매방 목록 : #{redis.lrange('guiltygear:rooms', 0, -1).join(' ')}")
        else
          bot.api.send_message(chat_id: chat_id, text: "#{room_number}는 없는 플매방 번호임.")
        end
      when '모두삭제'
        redis.del("guiltygear:rooms")
        bot.api.send_message(chat_id: chat_id, text: "플매방 모두 삭제 성공!")
      when '전부삭제'
        redis.del("guiltygear:rooms")
        bot.api.send_message(chat_id: chat_id, text: "플매방 모두 삭제 성공!")
      when '목록'
        bot.api.send_message(chat_id: chat_id, text: "현재 플매방 목록 : #{rooms.join(' ')}")
      else
        bot.api.send_message(chat_id: chat_id, text: "김길티 추가 방번호 - 플매방 추가하기\n김길티 삭제 방번호 - 플매방 삭제하기\n김길티 목록 - 플매방 목록 보기\n김길티 모두삭제 - 플매방 모두 삭제하기")
      end
    end

    head :ok, content_type: "text/html"
  end
end
