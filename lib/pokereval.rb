$:.unshift File.dirname(__FILE__)
module Pokereval
    BasePath = File.expand_path(File.dirname(__FILE__))

    require File.expand_path(File.dirname(__FILE__) + '/pokereval/values')
    require File.expand_path(File.dirname(__FILE__) + '/pokereval/raw_util')
    require File.expand_path(File.dirname(__FILE__) + '/pokereval/raw_lookup_evaluator')
end