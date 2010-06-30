#!/usr/bin/ruby
# netsed Unit::Tests
# (c) 2010 Julien Viard de Galbert <julien@silicone.homelinux.org>
#
# this tests check several behaviour of netsed regarding tcp connections
#

require 'test/unit'
require 'test_helper'

class TC_TCPTest < Test::Unit::TestCase
  SERVER=LH_IPv4
  
  def setup
    #puts self.class::SERVER
    @netsed = NetsedRun.new('tcp', LPORT, self.class::SERVER, RPORT, 's/andrew/mike')
  end

  def teardown
    @netsed.kill
  end

  def test_case_01_ServerDisconnect
    datasent   = 'test andrew and andrew'
    dataexpect = 'test mike and mike'
    serv = TCPServeSingleDataSender.new(self.class::SERVER, RPORT, datasent)
    datarecv = TCPSingleDataRecv(self.class::SERVER, LPORT, 100)
    serv.join
    assert_equal(dataexpect, datarecv)
  end

  def test_case_02_NoServer
    datarecv = TCPSingleDataRecv(self.class::SERVER, LPORT, 100)
    assert_equal('', datarecv)
  end

  def test_case_03_ClientSendData
    datasent   = 'test andrew and andrew'
    dataexpect = 'test mike and mike'

    serv = TCPServeSingleDataReciever.new(self.class::SERVER, RPORT, 100)
    TCPSingleDataSend(self.class::SERVER, LPORT, datasent)
    datarecv=serv.join
    assert_equal(dataexpect, datarecv)
  end

  def test_case_04_Chat
    datasent = ['client: bla bla andrew', 'server: ok andrew ok']
    dataexpect = ['client: bla bla mike', 'server: ok mike ok']
    datarecv = []
    serv = TCPServeSingleConnection.new(self.class::SERVER, RPORT) { |s|
      @tc4data = s.recv( 100 )
      s.write(datasent[1])
    }
    streamSock = TCPSocket.new(self.class::SERVER, LPORT)  
    streamSock.write( datasent[0] )  
    datarecv[1] = streamSock.recv( 100 )
    streamSock.close
    serv.join
    datarecv[0] = @tc4data

    assert_equal_objects(dataexpect, datarecv)
  end


  # check that netsed is still here for the test_group_all call ;)
  def test_case_zz_LastCheck
    datasent   = 'test andrew and andrew'
    dataexpect = 'test mike and mike'
    serv = TCPServeSingleDataSender.new(self.class::SERVER, RPORT, datasent)
    datarecv = TCPSingleDataRecv(self.class::SERVER, LPORT, 100)
    serv.join
    assert_equal(dataexpect, datarecv)
  end

  # this method rerun all 'test_case*' methods in one test to allow check that netsed is not crashed by any test.
  def test_group_all
    tests = self.class::get_all_test_case
    tests.sort.each { |test|
      __send__(test)
    }
  end

private

  def self.get_all_test_case
    method_names = public_instance_methods(true)
    return method_names.delete_if {|method_name| method_name !~ /^test_case./}
  end

end

# rerun all TCP tests with IPv6 localhost
# inspired by http://www.ruby-forum.com/topic/204730
TC_TCPTest6=Class.new(TC_TCPTest)
TC_TCPTest6.const_set(:SERVER, LH_IPv6)

# vim:sw=2:sta:et: