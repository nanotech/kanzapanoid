require 'spec_helper'
require 'backpack'

describe Backpack do

	before :each do
		@bp = Backpack.new(nil)
	end

	it "should keep any items put in it" do
		@bp.push 'foo'
		@bp.get(String).should == 'foo'
	end

	it "should be empty after having all it's items removed" do
		@bp.push 'foo'
		@bp.get(String).should == 'foo'
		@bp.get(String).should == nil
	end

	it "should sort items into groups" do
		item = mock('item')
		item.stub!(:class).and_return(:Foo)
		@bp.push item
		@bp.get(:Foo).should == item
	end

end
