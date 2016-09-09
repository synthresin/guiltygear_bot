require 'telegram/bot'
require 'pry'
require 'redis'
require 'logger'

# daemonize
Process.daemon(true,true)

# write pid to a .pid file
pid_file = File.dirname(__FILE__) + "#{__FILE__}.pid"
File.open(pid_file, 'w') { |f| f.write Process.pid }

token = '257493779:AAEWFMdfDhlnK8isYU0NdrTtq14N8SnXask'
room_regex = /\A[a-z0-9]{4}\z/i
redis = Redis.new
log = Logger.new(File.expand_path("..", Dir.pwd) + "log/#{__FILE__}.log", 'monthly')
log.debug 'bot initiated'

Telegram::Bot::Client.run(token) do |bot|
  begin
    bot.listen do |message|
      next unless message.text
      args = message.text.split
      next unless args[0] == "김길티" || args[0] == "김길티!"

      command = args[1]
      rooms = redis.lrange('guiltygear:rooms', 0, -1)

      case command
      when '추가'
        room_number = args[2]

        if room_number == nil
          bot.api.send_message(chat_id: message.chat.id, text: "추가할 플매방 번호를 빼먹음. 예) 김길티 추가 39fh")
          next
        end

        if room_regex.match(room_number)
          if rooms.include?(room_number)
            bot.api.send_message(chat_id: message.chat.id, text: "#{room_number}는 이미 있는 플매방 번호임")
          else
            redis.lpush("guiltygear:rooms", room_number)
            bot.api.send_message(chat_id: message.chat.id, text: "#{room_number} 플매방 추가 성공!\n현재 플매방 목록 : #{redis.lrange('guiltygear:rooms', 0, -1).join(' ')}")
            # TODO : rooms 목록을 가지고 공지를 새로 작성
          end
        else
          bot.api.send_message(chat_id: message.chat.id, text: "#{room_number}는 잘못된 방번호임. 4자리 숫자-알파벳 조합만 가능.")
        end

      when '삭제'
        room_number = args[2]

        if room_number == nil
          bot.api.send_message(chat_id: message.chat.id, text: "삭제할 플매방 번호를 빼먹음. 예) 김길티 삭제 39fh")
          next
        end

        if rooms.include?(room_number)
          redis.lrem("guiltygear:rooms", 0, room_number)
          bot.api.send_message(chat_id: message.chat.id, text: "#{room_number} 플매방 삭제 성공!\n현재 플매방 목록 : #{redis.lrange('guiltygear:rooms', 0, -1).join(' ')}")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "#{room_number}는 없는 플매방 번호임.")
        end
      when '모두삭제'
        redis.del("guiltygear:rooms")
        bot.api.send_message(chat_id: message.chat.id, text: "플매방 모두 삭제 성공!")
      when '전부삭제'
        redis.del("guiltygear:rooms")
        bot.api.send_message(chat_id: message.chat.id, text: "플매방 모두 삭제 성공!")
      when '목록'
        bot.api.send_message(chat_id: message.chat.id, text: "현재 플매방 목록 : #{rooms.join(' ')}")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "김길티 추가 방번호 - 플매방 추가하기\n김길티 삭제 방번호 - 플매방 삭제하기\n김길티 목록 - 플매방 목록 보기\n김길티 모두삭제 - 플매방 모두 삭제하기")
      end
    end
  rescue Exception => e
    log.error e.message
    log.error e.backtrace.inspect
  end
end
