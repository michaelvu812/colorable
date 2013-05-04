module Colorable
  module Converter
    class NoNameError < StandardError; end
  
    def name2rgb(name)
      COLORNAMES.assoc(name)[1]
    rescue
      raise NoNameError, "'#{name}' not exist"
    end

    def rgb2name(rgb)
      COLORNAMES.rassoc(validate_rgb rgb)
                .tap { |c, _| break c if c }
    end

    def rgb2hsb(rgb)
      r, g, b = validate_rgb(rgb).map(&:to_f)
      hue = Math.atan2(Math.sqrt(3)*(g-b), 2*r-g-b).to_degree

      min, max = [r, g, b].minmax
      sat = [min, max].all?(&:zero?) ? 0.0 : ((max - min) / max * 100)

      bright = max / 2.55
      [hue, sat, bright].map(&:round)
    end
    alias :rgb2hsv :rgb2hsb

    class NotImplemented < StandardError; end
    def rgb2hsl(rgb)
      raise NotImplemented, 'Not Implemented Yet'
      r, g, b = validate_rgb(rgb).map(&:to_f)
      hue = Math.atan2(Math.sqrt(3)*(g-b), 2*r-g-b).to_degree

      min, max = [r, g, b].minmax
      sat = [min, max].all?(&:zero?) ? 0.0 : ((max - min) / (1-(max+min-1).abs) * 100)

      lum = 0.298912*r + 0.586611*g + 0.114478*b
      [hue, sat, lum].map(&:round)
    end

    def hsb2rgb(hsb)
      hue, sat, bright = validate_hsb(hsb)
      norm = ->range{ hue.norm(range, 0..255) }
      rgb_h =
        case hue
        when 0..60    then [255, norm[0..60], 0]
        when 60..120  then [255-norm[60..120], 255, 0]
        when 120..180 then [0, 255, norm[120..180]]
        when 180..240 then [0, 255-norm[180..240], 255]
        when 240..300 then [norm[240..300], 0, 255]
        when 300..360 then [255, 0, 255-norm[300..360]]
        end
      rgb_s = rgb_h.map { |val| val + (255-val) * (1-sat/100.0) }
      rgb_s.map { |val| (val * bright/100.0).round }
    end
    alias :hsv2rgb :hsb2rgb

    def rgb2hex(rgb)
      hex = validate_rgb(rgb).map do |val|
        val.to_s(16).tap { |h| break "0#{h}" if h.size==1 }
      end
      '#' + hex.join.upcase
    end

    def hex2rgb(hex)
      _, *hex = validate_hex(hex).unpack('A1A2A2A2')
      hex.map { |val| val.to_i(16) }
    end
  
    private
    def validate(type, pattern, data)
      case Array(data)
      when Pattern[*Array(pattern)] then data
      else
        raise ArgumentError, "'#{data}' is invalid for a #{type} value"
      end
    end

    def validate_rgb(rgb)
      validate(:RGB, [0..255, 0..255, 0..255], rgb)
    end

    def validate_hsb(hsb)
      validate(:HSB, [0..359, 0..100, 0..100], hsb)
    end
  
    def validate_hex(hex)
      validate(:HEX, /^#[0-9A-F]{6}$/i, hex)
    end
  end
end