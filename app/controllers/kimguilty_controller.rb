require 'telegram/bot'

class KimguiltyController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    token = Rails.env.production? ? '257493779:AAEWFMdfDhlnK8isYU0NdrTtq14N8SnXask' : '239356367:AAEvlpyaxnrP9nZKm5U7OXn1MpGR2DbFukY'

    text = params[:message] && params[:message][:text]
    return head :ok, content_type: "text/html" unless text

    args = text.split
    chat_id = params[:message][:chat][:id]

    return head :ok, content_type: "text/html" unless args[0] == "김길티" || args[0] == "김길티!"

    command = args[1]

    Telegram::Bot::Client.run(token) do |bot|
      code = args[2]

      case command
      when '추가'
        room = Room.new(code: code)
        if room.save
          bot.api.send_message(chat_id: chat_id, text: "#{room.code} 플매방 추가 성공!\n\n#{Room.list_message}", parse_mode: "Markdown")
        else
          bot.api.send_message(chat_id: chat_id, text: room.bot_error_message)
        end
      when '삭제'
        if code == nil
          bot.api.send_message(chat_id: chat_id, text: "삭제할 플매방 번호를 빼먹음. 예) 김길티 삭제 39fh")
          next
        end

        room = Room.find_by(code: code)
        if room
          room.destroy
          bot.api.send_message(chat_id: chat_id, text: "#{code} 플매방 삭제 성공!\n\n#{Room.list_message}", parse_mode: "Markdown")
        else
          bot.api.send_message(chat_id: chat_id, text: "#{code}는 없는 플매방 번호임.")
        end
      when '모두삭제', '전부삭제'
        Room.destroy_all
        bot.api.send_message(chat_id: chat_id, text: "플매방 모두 삭제 성공!")
      when '목록'
        bot.api.send_message(chat_id: chat_id, text: Room.list_message, parse_mode: "Markdown")
      else
        bot.api.send_message(chat_id: chat_id, text: "김길티 추가 방번호 - 플매방 추가하기\n김길티 삭제 방번호 - 플매방 삭제하기\n김길티 목록 - 플매방 목록 보기\n김길티 모두삭제 - 플매방 모두 삭제하기")
      end
    end

    head :ok, content_type: "text/html"
  end
end
