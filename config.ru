$:.unshift File.expand_path('../lib', __FILE__)

require 'travis/log_streaming'

Travis::LogStreaming.setup
Travis::LogStreaming.connect

run Travis::LogStreaming::App
