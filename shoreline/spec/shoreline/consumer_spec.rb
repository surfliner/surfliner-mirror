require "spec_helper"
require "shoreline/consumer"

RSpec.describe Shoreline::Consumer do
  describe Shoreline::Consumer::Connection do
    subject(:connection) { described_class.new }

    describe "#connect" do
      it "establishes a connection" do
        expect { connection.connect }
          .to change { connection.connection&.status }
          .to(:open)
      end

      it "opens a channel" do
        expect { connection.connect }
          .to change { connection.channel&.status }
          .to(:open)
      end
    end

    describe "#close" do
      it "closes a connection" do
        connection.connect

        expect { connection.close }
          .to change { connection.connection&.status }
          .from(:open)
          .to(:closed)
      end

      it "closes a channel" do
        connection.connect

        expect { connection.close }
          .to change { connection.channel&.status }
          .from(:open)
          .to(:closed)
      end

      it "when the channel isn't open still closes connection it's not open" do
        connection.connect
        connection.channel.close

        expect {
          begin
            connection.close
          rescue
            Bunny::ChannelAlreadyClosed
          end
        }
          .to change { connection.connection&.status }
          .to(:closed)
      end
    end
  end
end
