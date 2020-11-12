require 'shellwords'
require 'fileutils'

module Ag
  class Recording
    AGQR_STREAM_URL = 'https://fms2.uniqueradio.jp/agqr10/aandg1.m3u8'
    CH_NAME = 'ag'

    def record(job)
      return false unless exec_rec(job)

      exec_convert(job)
      true
    end

    def exec_rec(job)
      Main.prepare_working_dir(CH_NAME)
      Main.sleep_until(job.start - 10.seconds)

      length = job.length_sec + 60
      tmp_path = Main.file_path_working(CH_NAME, title(job), 'mp4')
      command = "ffmpeg -i #{Shellwords.escape(AGQR_STREAM_URL)} -t #{length} -c copy #{Shellwords.escape(tmp_path)}"
      exit_status, output = Main.shell_exec(command)
      unless exit_status.success?
        Rails.logger.error "rec failed. job:#{job}, exit_status:#{exit_status}, output:#{output}"
        return false
      end

      true
    end

    def exec_convert(job)
      mp4_path = Main.file_path_working(CH_NAME, title(job), 'mp4')
      Main.move_to_archive_dir(CH_NAME, job.start, mp4_path)
    end

    def title(job)
      date = job.start.strftime('%Y_%m_%d_%H%M')
      "#{date}_#{job.title}"
    end
  end
end
