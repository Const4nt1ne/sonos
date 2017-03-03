module MonitorSonos
  class MonitorMusic
    def initialize
      @speakers = MonitorSonos.speakers
      @logfile = "#{MonitorSonos.root}/logs/music.log"
      @logger ||= music_logger
      @heartbeat = 30
    end

    def self.init
      Thread.new { new.send(:init) }
    end

    private
    def init
      while true
        @speakers.each do |ip, details|
          next if details[:playing].nil?
          artist = details[:playing][:artist]
          title = details[:playing][:title]
          album = details[:playing][:album]
          msg = "#{artist} #{album} #{title}"
          @logger.info msg unless exists? msg
          sleep 0.2 # lazy wait to avoid saving N speaker music lines
        end
        sleep @heartbeat
      end
    end

    def exists?(string)
      fresh = false
      File.readlines(@logfile).each do |line|
        if line.match(string)
          fresh = true
          break
        end
      end
      fresh
    end

    def music_logger
      FileUtils.touch @logfile unless File.exist? @logfile
      Logger.new(@logfile, 'daily').tap do |l|
        l.formatter = proc do |severity, datetime, progname, msg|
          date_format = datetime.strftime '%Y-%m-%d %H:%M:%S '
          "#{date_format} #{msg}\n"
        end
      end
    end
  end
end