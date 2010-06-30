#!/usr/bin/ruby
# netsed Unit::Tests
# (c) 2010 Julien Viard de Galbert <julien@silicone.homelinux.org>
#
# this tests check the TTL (time-to-live) feature on netsed rules

require 'test/unit'
require 'test_helper'

class TC_TTLTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_TTL_basic
    datasent   = 'test andrew and andrew'
    dataexpect = 'test mike and andrew'
    serv = TCPServeSingleDataSender.new(SERVER, RPORT, datasent)

    netsed = NetsedRun.new('tcp', LPORT, SERVER, RPORT, 's/andrew/mike/1')

    datarecv = TCPSingleDataRecv(SERVER, LPORT, 100)

    serv.join
    netsed.kill

    assert_equal(dataexpect, datarecv)
  end

  def test_TTL_20
    datasent   = '% %% %%% %%%% %%%%% %%%%%% %%%%%%%'
    dataexpect = '/ // /// //// ///// /////% %%%%%%%'
    serv = TCPServeSingleDataSender.new(SERVER, RPORT, datasent)

    netsed = NetsedRun.new('tcp', LPORT, SERVER, RPORT, 's/%%/%2f/20')

    datarecv = TCPSingleDataRecv(SERVER, LPORT, 100)

    serv.join
    netsed.kill

    assert_equal(dataexpect, datarecv)
  end

end

# vim:sw=2:sta:et:
