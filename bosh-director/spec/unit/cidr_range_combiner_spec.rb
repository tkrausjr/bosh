require 'spec_helper'

module Bosh::Director
  describe CidrRangeCombiner do
    subject(:range_combiner) { CidrRangeCombiner.new }

    describe 'chaos' do
      let(:cidr_ranges) do
        [
          NetAddr::CIDR.create('192.168.0.8/31'),
          NetAddr::CIDR.create('192.168.0.6/32'),
          NetAddr::CIDR.create('192.168.0.13/32'),
          NetAddr::CIDR.create('192.168.1.1/24'),
          NetAddr::CIDR.create('192.168.0.10/32'),
          NetAddr::CIDR.create('192.168.2.1/24'),
          NetAddr::CIDR.create('192.168.0.14/31'),
        ]
      end

      it 'creates sense' do
        expect(range_combiner.combine_ranges(cidr_ranges)).to eq(
          [['192.168.0.6', '192.168.0.6'],
            ['192.168.0.8', '192.168.0.10'],
            ['192.168.0.13', '192.168.0.15'],
            ['192.168.1.0', '192.168.2.255'] ]
        )
      end
    end

    describe 'when the a range is length 1' do
      let(:cidr_ranges) do
        [
          NetAddr::CIDR.create('192.168.0.8/32'),
          NetAddr::CIDR.create('192.168.0.6/32'),
        ]
      end

      it 'returns tuples with same first and last value' do
        expect(range_combiner.combine_ranges(cidr_ranges)).to eq(
          [ ['192.168.0.6', '192.168.0.6'], ['192.168.0.8', '192.168.0.8']  ]
        )
      end
    end

    describe 'when the ranges do not overlap' do
      let(:cidr_ranges) do
        [
          NetAddr::CIDR.create('192.168.0.8/31'),
          NetAddr::CIDR.create('192.168.0.6/32'),
        ]
      end

      it 'does not combine the ranges' do
        expect(range_combiner.combine_ranges(cidr_ranges)).to eq(
          [ ['192.168.0.6', '192.168.0.6'], ['192.168.0.8', '192.168.0.9']  ]
        )
      end
    end

    describe 'when a range is a subset of another range' do
      let(:cidr_ranges) do
        [
          NetAddr::CIDR.create('192.168.0.0/24'), # 0-255
          NetAddr::CIDR.create('192.168.0.10/30'), # 8-11
        ]
      end

      it 'combines the ranges' do
        expect(range_combiner.combine_ranges(cidr_ranges)).to eq(
          [ ['192.168.0.0', '192.168.0.255'] ]
        )
      end
    end

    describe 'when ranges are adjacent' do
      let(:cidr_ranges) do
        [
          NetAddr::CIDR.create('192.168.0.8/30'), # 8-11
          NetAddr::CIDR.create('192.168.0.12/30'), #12-15
        ]
      end

      it 'combines the ranges' do
        expect(range_combiner.combine_ranges(cidr_ranges)).to eq(
          [ ['192.168.0.8', '192.168.0.15'] ]
        )
      end
    end
  end
end
