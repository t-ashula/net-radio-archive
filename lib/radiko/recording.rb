require 'net/https'
require 'shellwords'
require 'fileutils'
require 'base64'
require 'active_support'
require 'active_support/core_ext'

module Radiko
  class Recording
    WORK_DIR_NAME = 'radiko'

    def initialize
      @cookie = ''
    end

    def record(job)
      return false unless exec_rec(job)
      exec_convert(job)
      true
    end

    def exec_rec(job)
      begin
        Main::prepare_working_dir(WORK_DIR_NAME)
        Main::prepare_working_dir(job.ch)
        Main::retry do
          auth(job)
        end
        rec(job)
      ensure
        logout
      end
    end

    def auth(job)
      login(job)
      auth1
      auth2
    end

    def login(job)
      if !Settings.radiko_premium ||
          !Settings.radiko_premium.mail ||
          !Settings.radiko_premium.password ||
          !Settings.radiko_premium.channels.include?(job.ch)
        return
      end
      uri = URI('https://radiko.jp/v4/api/member/login')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.start do |h|
        req = Net::HTTP::Post.new(uri.path)
        req.set_form_data(
            'mail' => Settings.radiko_premium.mail,
            'pass' => Settings.radiko_premium.password
        )
        res = h.request(req)
        # @cookie = res.response['set-cookie']
        @session = JSON.parse(res.body)
      end
    end

    JS_PLAYER_KEY = "bcd151073c03b352e1ef2fd66c32209da9ca0afa"

    def auth1
      uri = URI('https://radiko.jp/v2/api/auth1')
      req = Net::HTTP::Get.new(
        uri,
        'X-Radiko-App' => 'pc_html5',
        'X-Radiko-App-Version' => '0.0.1',
        'X-Radiko-User' => 'test-stream',
        'X-Radiko-Device' => 'pc'
      )
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = https.start { |h| h.request(req) }

      @auth_token = res.header['x-radiko-authtoken']
      @offset = res.header['x-radiko-keyoffset'].to_i
      @length = res.header['x-radiko-keylength'].to_i
    end

    def partialkey
      Base64.strict_encode64(JS_PLAYER_KEY[@offset...(@offset + @length)])
    end

    def logined?
      @session && @session['radiko_session']
    end

    def auth2
      uri = URI('https://radiko.jp/v2/api/auth2')
      if logined?
        uri.query = "radiko_session=#{@session['radiko_session']}"
      end

      req = Net::HTTP::Get.new(
        uri,
        'X-Radiko-User' => 'test-stream',
        'X-Radiko-Device' => 'pc',
        'X-Radiko-Authtoken' => @auth_token,
        'X-Radiko-Partialkey' => partialkey
      )
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.start do |h|
        h.request(req)
      end
    end

    def rec(job)
      Main::sleep_until(job.start - 10.seconds)

      uri = URI.parse("http://radiko.jp/v2/station/stream_smh_multi/#{job.ch}.xml")
      res = Net::HTTP.get(uri)
      urls = Hash.from_xml(res)
      areafree = logined? ? "1" : "0"
      playlist_url = urls['urls']['url'].find { |u| u['areafree'] == areafree }["playlist_create_url"]
      out_path = Main::file_path_working(job.ch, title(job), 'm4a')
      arg = "\
        -loglevel error \
        -y \
        -headers \"X-Radiko-Authtoken: #{@auth_token}\" \
        -i #{Shellwords.escape(playlist_url)} \
        -acodec copy \
        -vn \
        -bsf:a aac_adtstoasc \
        -t #{job.length_sec + 60} \
        #{Shellwords.escape(out_path)} \
      "
      exit_status, output = Main::ffmpeg(arg)
      unless exit_status.success?
        Rails.logger.error "rec failed. ffmpeg: #{arg}, job:#{job.id}, exit_status:#{exit_status}, output:#{output}"
        return false
      end

      true
    end

    def hms(sec)
      h = sec / 3600
      m = (sec % 3600) / 60
      s = (sec % 3600) % 60
      format "%02d:%02d:%02d", h, m, s
    end

    def logout
      return if @session.nil?

      uri = URI.parse('https://radiko.jp/v4/api/member/logout')
      res = Net::HTTP.post_form(uri, "radiko_session" => @session["radiko_session"])
      res.body
    end

    def exec_convert(job)
      tmp_path = Main::file_path_working(job.ch, title(job), 'm4a')
      if Settings.force_mp4
        mp4_path = Main::file_path_working(job.ch, title(job), 'mp4')
        Main::convert_ffmpeg_to_mp4_with_blank_video(tmp_path, mp4_path, job)
        src_path = mp4_path
      else
        src_path = tmp_path
      end
      Main::move_to_archive_dir(job.ch, job.start, src_path)
    end

    def title(job)
      date = job.start.strftime('%Y_%m_%d_%H%M')
      "#{date}_#{job.title}"
    end

    def swf_path
      Main::file_path_working_base(WORK_DIR_NAME, "player2.swf")
    end

    def key_path
      Main::file_path_working_base(WORK_DIR_NAME, "radiko_key2.png")
    end
  end
end
