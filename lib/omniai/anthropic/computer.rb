# frozen_string_literal: true

require "open3"

module OmniAI
  module Anthropic
    # A reference implementation of an OmniAI computer tool using xdotool for mouse / keyboard:
    # https://docs.anthropic.com/en/docs/build-with-claude/computer-use#computer-tool
    #
    # Usage:
    #
    #   computer = OmniAI::Anthropic::Computer.new()
    class Computer
      TYPE = "computer_20241022"

      SCREENSHOT_DELAY = 2.0 # seconds
      TYPING_DELAY = 20 # milliseconds

      module Action
        KEY = "key"
        TYPE = "type"
        CURSOR_POSITION = "cursor_position"
        MOUSE_MOVE = "mouse_move"
        LEFT_CLICK = "left_click"
        RIGHT_CLICK = "right_click"
        MIDDLE_CLICK = "middle_click"
        LEFT_CLICK_DRAG = "left_click_drag"
        RIGHT_CLICK_DRAG = "right_click_drag"
        MIDDLE_CLICK_DRAG = "middle_click_drag"
        DOUBLE_CLICK = "double_click"
        SCREENSHOT = "screenshot"
      end

      module Button
        LEFT = 1
        MIDDLE = 2
        RIGHT = 3
      end

      # @attribute [rw] name
      #   @return [String]
      attr_accessor :name

      # @param name [String] optional
      # @param display_width_px [Integer]
      # @param display_height_px [Integer]
      # @param display_number [Integer] optional
      def initialize(display_width_px:, display_height_px:, display_number: 1, name: "computer")
        @name = name
        @display_width_px = display_width_px
        @display_height_px = display_height_px
        @display_number = display_number
      end

      # @example
      #   tool.serialize # =>
      #   # {
      #   #  "type": "computer_20241022",
      #   #  "name": "computer",
      #   #  "display_width_px": 1024,
      #   #  "display_height_px": 768,
      #   #  "display_number": 1,
      #   # }
      #
      # @return [Hash]
      def serialize(*)
        {
          type: TYPE,
          name: @name,
          display_width_px: @display_width_px,
          display_height_px: @display_height_px,
          display_number: @display_number,
        }
      end

      # @example
      #   computer.call({ "action" => 'type', "text" => 'Hello' })
      #
      # @param args [Hash]
      # @return [String]
      def call(args = {})
        perform(
          action: args["action"],
          text: args["text"],
          coordinate: args["coordinate"]
        )
      end

      # @param action [String]
      # @param coordinate [Array] [x, y] optional
      # @param text [String] optional
      #
      # @return [Array<Hash>]
      def perform(action:, text: nil, coordinate: nil) # rubocop:disable Metrics/CyclomaticComplexity
        case action
        when Action::KEY then key(text:)
        when Action::TYPE then type(text:)
        when Action::CURSOR_POSITION then mouse_location
        when Action::LEFT_CLICK then click(button: Button::LEFT)
        when Action::MIDDLE_CLICK then click(button: Button::MIDDLE)
        when Action::RIGHT_CLICK then click(button: Button::RIGHT)
        when Action::LEFT_CLICK_DRAG then mouse_down_move_up(coordinate:, button: Button::LEFT)
        when Action::MIDDLE_CLICK_DRAG then mouse_down_move_up(coordinate:, button: Button::MIDDLE)
        when Action::RIGHT_CLICK_DRAG then mouse_down_move_up(coordinate:, button: Button::RIGHT)
        when Action::MOUSE_MOVE then mouse_move(coordinate:)
        when Action::DOUBLE_CLICK then double_click(button: Button::LEFT)
        when Action::SCREENSHOT then screenshot
        end
      end

      # @param cmd [String]
      #
      # @return [String]
      def shell(cmd, ...)
        stdout, stderr, status = Open3.capture3(cmd, ...)

        "stdout=#{stdout.inspect} stderr=#{stderr.inspect} status=#{status}"
      end

      # @return [String]
      def xdotool(...)
        shell("xdotool", ...)
      end

      # @param button [Integer]
      #
      # @return [String]
      def click(button:)
        xdotool("click", button)
      end

      # @param button [Integer]
      #
      # @return [String]
      def double_click(button:)
        xdotool("click", button, "--repeat", 2)
      end

      # @param coordinate [Array] [x, y]
      #
      # @return [String]
      def mouse_move(coordinate:)
        x, y = coordinate
        xdotool("mousemove", "--sync", x, y)
      end

      # @param coordinate [Array] [x, y]
      # @param button [Integer]
      #
      # @return [String]
      def mouse_down_move_up(coordinate:, button:)
        x, y = coordinate
        xdotool("mousedown", button, "mousemove", "--sync", x, y, "mouseup", button)
      end

      # @return [String]
      def mouse_location
        xdotool("getmouselocation")
      end

      # @param text [String]
      # @param delay [Integer] milliseconds
      #
      # @return [String]
      def type(text:, delay: TYPING_DELAY)
        xdotool("type", "--delay", delay, "--", text)
      end

      # @param text [String]
      #
      # @return [String]
      def key(text:)
        xdotool("key", "--", text)
      end

      # @return [Hash]
      def screenshot
        tempfile = Tempfile.new(["screenshot", ".png"])
        Kernel.system("gnome-screenshot", "-w", "-f", tempfile.path)
        tempfile.rewind
        data = Base64.encode64(tempfile.read)

        { type: "base64", media_type: "image/png", data: }
      ensure
        tempfile.close
        tempfile.unlink
      end
    end
  end
end
