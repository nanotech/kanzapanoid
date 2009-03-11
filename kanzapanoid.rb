#!/usr/bin/env ruby

#
# Run this file to start the game.
#

$LOAD_PATH.push 'lib/'
require 'screens'

#
# The main, top-level game class.
#
class Kanzapanoid < Screens
	NAME = 'kanzapanoid'
	MAINTAINER = 'nanotech'

	def initialize
		super('Kanzapanoid', 1280, Rational(16,10))
		switch_to 'game'
	end
end

Kanzapanoid.new.show
