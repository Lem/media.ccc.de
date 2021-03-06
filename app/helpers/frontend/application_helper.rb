module Frontend
  module ApplicationHelper
    require 'uri'

    def oembed_show_event_url(event)
      Settings.oembed_url + oembed_event_url(slug: event.slug)
    end

    def twitter_url(title, url)
      'http://twitter.com/home?status=' + URI.encode_www_form_component(title + ': ' + url)
    end

    def facebook_url(title, url)
      'https://www.facebook.com/sharer/sharer.php?t=' + URI.encode_www_form_component(title) + '&u=' + URI.encode_www_form_component(url)
    end

    def googleplus_url(title, url)
      'https://plus.google.com/share?title=' + URI.encode_www_form_component(title) + '&url=' + URI.encode_www_form_component(url)
    end

    def appnet_url(title, url)
      'https://alpha.app.net/intent/post?text=' + URI.encode_www_form_component(title + ': ' + url)
    end

    # TODO FIXME
    def mail_url(title, url)
      content = URI.encode_www_form_component(title + ': ' + url)
      subject = URI.encode_www_form_component(title)
      URI::MailTo.build(['', [['Subject', subject], ['Body', content]]]).to_s
    end

    def breadcrumbs_trail
      path = if @conference
               @conference.slug
             elsif @folders
               @folders.last.parent_path
             else
               ''
             end
      parts = path.split('/')
      return if parts.blank?
      parts += ['event'] if @event
      current = parts.pop
      yield parts, current
    end

    def video_download_sources(recordings)
      skip = %w(vnd.voc/mp4-web vnd.voc/webm-web)
      recordings.reject { |r| skip.include? r.mime_type }
    end

    def video_tag_sources(recordings, order = MimeType::WEB_PREFERRED_VIDEO)
      scores = {}
      recordings.select { |r| order.include? r.mime_type }.each do |r|
        pos = order.index r.mime_type
        fail r.mime_type unless pos
        if scores.key? r.display_mime_type
          scores[r.display_mime_type] = pos unless scores[r.display_mime_type] < pos
        else
          scores[r.display_mime_type] = pos
        end
      end
      scores.map do |_, pos|
        mime_type = order[pos]
        recordings.detect { |r| r.mime_type == mime_type }
      end
    end

    def keywords
      if @event && @event.tags
        [@event.tags, Settings.header['keywords']].join(', ')
      else
        Settings.header['keywords']
      end
    end

    def recording_length_minutes(recording)
      "#{recording.length / 60} min" if recording.length > 0
    end

    def duration_in_minutes(duration)
      "#{duration / 60} min" if duration > 0
    end

    def video_for_flash(recordings)
      url = recordings.find { |recording| recording.display_mime_type == 'video/mp4' }.try(:url)
      if url.present?
        h(url)
      elsif recordings.present?
        h(recordings.first.url)
      else
        # :(
        ''
      end
    end

    def aspect_ratio_width(high = true)
      conference = @conference
      case conference.aspect_ratio
      when /16:9/
        high ? '640' : '188'
      when /4:3/
        high ? '400' : '120'
      end
    end

    def aspect_ratio_height(high = true)
      conference = @conference
      case conference.aspect_ratio
      when /16:9/
        high ? '360' : '144'
      when /4:3/
        high ? '300' : '90'
      end
    end

    def parse_url_host(_urlish)
      URI.parse(@event.link).host
    rescue URI::InvalidURIError
      return ''
    end

    def linked_persons_text(persons)
      if persons.length == 0
        'n/a'
      elsif persons.length == 1
        linkify_persons(persons)[0]
      else
        persons = linkify_persons(persons)
        persons = persons[0..-3] + [persons[-2..-1].join(' and ')]
        persons.join(', ')
      end
    end

    def linkify_persons(persons)
      persons.map { |person| '<a href="/search/?q=' + CGI.escapeHTML(CGI.escape(person)) + '">' + CGI.escapeHTML(person) + '</a>' }
    end

    def persons_icon(persons)
      if persons.length <= 1
        'fa-user'
      else
        'fa-group'
      end
    end
  end
end
