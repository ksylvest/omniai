# frozen_string_literal: true

RSpec.describe OmniAI::Anthropic::Computer do
  let(:computer) { described_class.new(display_width_px: 1280, display_height_px: 1024, display_number: 1) }

  describe "#serialize" do
    it "serializes the computer" do
      expect(computer.serialize).to eq(
        type: described_class::TYPE,
        name: "computer",
        display_width_px: 1280,
        display_height_px: 1024,
        display_number: 1
      )
    end
  end

  describe "#call" do
    let(:action) { described_class::Action::KEY }
    let(:text) { "!" }
    let(:coordinate) { nil }

    it "calls perform" do
      allow(computer).to receive(:perform)
      computer.call({ "action" => action, "text" => text, "coordinate" => coordinate })
      expect(computer).to have_received(:perform).with(action:, text:, coordinate:)
    end
  end

  describe "#perform" do
    let(:text) { nil }
    let(:coordinate) { nil }

    context 'when action is "key"' do
      let(:action) { described_class::Action::KEY }
      let(:text) { "!" }

      it "types the key" do
        allow(computer).to receive(:key)
        computer.perform(action:, text:)
        expect(computer).to have_received(:key).with(text:)
      end
    end

    context 'when action is "type"' do
      let(:action) { described_class::Action::TYPE }
      let(:text) { "Hello!" }

      it "types the text" do
        allow(computer).to receive(:type)
        computer.perform(action:, text:)
        expect(computer).to have_received(:type).with(text:)
      end
    end

    context 'when action is "cursor_position"' do
      let(:action) { described_class::Action::CURSOR_POSITION }
      let(:coordinate) { [0, 0] }

      it "retrieves the cursor position" do
        allow(computer).to receive(:mouse_location)
        computer.perform(action:)
        expect(computer).to have_received(:mouse_location)
      end
    end

    context 'when action is "mouse_move"' do
      let(:action) { described_class::Action::MOUSE_MOVE }
      let(:coordinate) { [0, 0] }

      it "moves the mouse" do
        allow(computer).to receive(:mouse_move)
        computer.perform(action:, coordinate:)
        expect(computer).to have_received(:mouse_move).with(coordinate:)
      end
    end

    context 'when action is "left_click"' do
      let(:action) { described_class::Action::LEFT_CLICK }

      it "clicks the left mouse button" do
        allow(computer).to receive(:click)
        computer.perform(action:)
        expect(computer).to have_received(:click)
          .with(button: described_class::Button::LEFT)
      end
    end

    context 'when action is "middle_click"' do
      let(:action) { described_class::Action::MIDDLE_CLICK }

      it "clicks the middle mouse button" do
        allow(computer).to receive(:click)
        computer.perform(action:)
        expect(computer).to have_received(:click)
          .with(button: described_class::Button::MIDDLE)
      end
    end

    context 'when action is "right_click"' do
      let(:action) { described_class::Action::RIGHT_CLICK }

      it "clicks the right mouse button" do
        allow(computer).to receive(:click)
        computer.perform(action:)
        expect(computer).to have_received(:click)
          .with(button: described_class::Button::RIGHT)
      end
    end

    context 'when action is "left_click_drag"' do
      let(:action) { described_class::Action::LEFT_CLICK_DRAG }
      let(:coordinate) { [0, 0] }

      it "drags the left mouse button" do
        allow(computer).to receive(:mouse_down_move_up)
        computer.perform(action:, coordinate:)
        expect(computer).to have_received(:mouse_down_move_up)
          .with(coordinate:, button: described_class::Button::LEFT)
      end
    end

    context 'when action is "middle_click_drag"' do
      let(:action) { described_class::Action::MIDDLE_CLICK_DRAG }
      let(:coordinate) { [0, 0] }

      it "drags the middle mouse button" do
        allow(computer).to receive(:mouse_down_move_up)
        computer.perform(action:, coordinate:)
        expect(computer).to have_received(:mouse_down_move_up)
          .with(coordinate:, button: described_class::Button::MIDDLE)
      end
    end

    context 'when action is "right_click_drag"' do
      let(:action) { described_class::Action::RIGHT_CLICK_DRAG }
      let(:coordinate) { [0, 0] }

      it "drags the right mouse button" do
        allow(computer).to receive(:mouse_down_move_up)
        computer.perform(action:, coordinate:)
        expect(computer).to have_received(:mouse_down_move_up)
          .with(coordinate:, button: described_class::Button::RIGHT)
      end
    end

    context 'when action is "double_click"' do
      let(:action) { described_class::Action::DOUBLE_CLICK }

      it "double clicks" do
        allow(computer).to receive(:double_click)
        computer.perform(action:)
        expect(computer).to have_received(:double_click)
      end
    end

    context 'when action is "screenshot"' do
      let(:action) { described_class::Action::SCREENSHOT }

      it "takes a screenshot" do
        allow(computer).to receive(:screenshot)
        computer.perform(action:)
        expect(computer).to have_received(:screenshot)
      end
    end
  end

  describe "#shell" do
    it "runs a shell command" do
      expect(computer.shell("pwd")).to be_a(String)
    end
  end

  describe "#xdotool" do
    it "runs xdotool" do
      allow(computer).to receive(:shell)
      computer.xdotool("mousemove", "0", "0")
      expect(computer).to have_received(:shell)
        .with("xdotool", "mousemove", "0", "0")
    end
  end

  describe "#click" do
    it "clicks the left mouse button" do
      allow(computer).to receive(:shell)
      computer.click(button: described_class::Button::LEFT)
      expect(computer).to have_received(:shell)
        .with("xdotool", "click", 1)
    end

    it "clicks the middle mouse button" do
      allow(computer).to receive(:shell)
      computer.click(button: described_class::Button::MIDDLE)
      expect(computer).to have_received(:shell)
        .with("xdotool", "click", 2)
    end

    it "clicks the right mouse button" do
      allow(computer).to receive(:shell)
      computer.click(button: described_class::Button::RIGHT)
      expect(computer).to have_received(:shell)
        .with("xdotool", "click", 3)
    end
  end

  describe "#double_click" do
    it "clicks the left mouse button" do
      allow(computer).to receive(:shell)
      computer.double_click(button: described_class::Button::LEFT)
      expect(computer).to have_received(:shell)
        .with("xdotool", "click", 1, "--repeat", 2)
    end

    it "clicks the middle mouse button" do
      allow(computer).to receive(:shell)
      computer.double_click(button: described_class::Button::MIDDLE)
      expect(computer).to have_received(:shell)
        .with("xdotool", "click", 2, "--repeat", 2)
    end

    it "clicks the right mouse button" do
      allow(computer).to receive(:shell)
      computer.double_click(button: described_class::Button::RIGHT)
      expect(computer).to have_received(:shell)
        .with("xdotool", "click", 3, "--repeat", 2)
    end
  end

  describe "#mouse_move" do
    it "moves the mouse" do
      allow(computer).to receive(:shell)
      computer.mouse_move(coordinate: [0, 0])
      expect(computer).to have_received(:shell)
        .with("xdotool", "mousemove", "--sync", 0, 0)
    end
  end

  describe "#mouse_down_move_up" do
    it "moves the mouse" do
      allow(computer).to receive(:shell)
      computer.mouse_down_move_up(coordinate: [0, 0], button: 0)
      expect(computer).to have_received(:shell)
        .with("xdotool", "mousedown", 0, "mousemove", "--sync", 0, 0, "mouseup", 0)
    end
  end

  describe "#mouse_location" do
    it "retrieves the mouse location" do
      allow(computer).to receive(:shell)
      computer.mouse_location
      expect(computer).to have_received(:shell)
        .with("xdotool", "getmouselocation")
    end
  end

  describe "#type" do
    it "types text" do
      allow(computer).to receive(:shell)
      computer.type(text: "Hello!")
      expect(computer).to have_received(:shell)
        .with("xdotool", "type", "--delay", 20, "--", "Hello!")
    end
  end

  describe "#key" do
    it "types text" do
      allow(computer).to receive(:shell)
      computer.key(text: "!")
      expect(computer).to have_received(:shell)
        .with("xdotool", "key", "--", "!")
    end
  end

  describe "#screenshot" do
    it "takes a screenshot" do
      allow(Kernel).to receive(:system)
      computer.screenshot
      expect(Kernel).to have_received(:system)
        .with("gnome-screenshot", "-w", "-f", anything)
    end
  end
end
