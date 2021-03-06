module Frontend
  class Event < ::Event
    belongs_to :conference, class_name: Frontend::Conference
    has_many :recordings, class_name: Frontend::Recording

    scope :promoted, ->(n) { where(promoted: true).order('updated_at desc').limit(n) }
    scope :recent, ->(n) { order('release_date desc').limit(n) }
    scope :newer, ->(date) { where('release_date > ?', date).order('release_date desc') }
    scope :older, ->(date) { where('release_date < ?', date).order('release_date desc') }
    scope :downloaded, -> { joins(:recordings).where(recordings: { state: 'downloaded', mime_type: MimeType::HTML5 }) }

    def title
      self[:title].strip
    end

    def display_date
      d = release_date || date
      d.strftime('%Y-%m-%d') if d
    end

    def poster_url
      File.join(Settings.static_url, conference.images_path, poster_filename) if poster_filename
    end

    def thumb_url
      if thumb_filename_exists?
        File.join Settings.static_url, conference.images_path, thumb_filename
      else
        conference.logo_url
      end
    end

    def tags
      self[:tags].compact.collect(&:strip)
    end

    def audio_recording
      preferred_recording(order: MimeType::AUDIO)
    end

    def preferred_recording(order: MimeType::PREFERRED_VIDEO)
      recordings = recordings_by_mime_type
      return if recordings.empty?
      order.each do |mt|
        return recordings[mt] if recordings.key?(mt)
      end
      recordings.first[1]
    end

    # @return [Array(Recording)]
    def by_mime_type(mime_type: 'video/mp4')
      recordings.downloaded.by_mime_type(mime_type).first
    end

    private

    def thumb_filename_exists?
      return if thumb_filename.blank?
      return unless File.readable?(File.join(conference.get_images_path, thumb_filename))
      true
    end

    def recordings_by_mime_type
      Hash[recordings.downloaded.map { |r| [r.mime_type, r] }]
    end
  end
end
