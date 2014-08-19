require 'spec_helper'

describe 'tomcat', :type => :class do

 it { should contain_class('tomcat') }
end

