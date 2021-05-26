# Copyright (c) 2021 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Settings ***
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/crypto/ipsec.robot
|
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | UDIR | PERFTEST | HW_ENV | RECONF
| ... | IP4FWD | IPSEC | IPSECSW | IPSECINT | NIC_Intel-X710 | SCALE | TNL_1000
| ... | AES_256_GCM | AES | 1_ADDED_TUNNEL | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir
|
| Suite Setup | Setup suite topology interfaces | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance | ipsec_sa
|
| Test Template | Local Template
|
| Documentation | *RFC2544: Packet loss IPv4 IPsec tunnel mode.*
|
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 on TG-DUT1,
| ... | Eth-IPv4-IPSec on DUT1-TG
| ... | *[Cfg] DUT configuration:* DUT1 is configured with multiple IPsec\
| ... | tunnels between it and TG. DUT gets IPv4 traffic from TG, encrypts it\
| ... | and sends back to TG.
| ... | *[Ver] TG verification:* TG finds throughput NDR (Non Drop Rate)\
| ... | with zero packet loss tolerance, then measures loss at this load\
| ... | while additional tunnels are configured.\
| ... | Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains one L3 flow-groups
| ... | (flow-group per direction, number of flows per flow-group equals to
| ... | number of IPSec tunnels) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and
| ... | static payload. MAC addresses are matching MAC addresses of the TG
| ... | node interfaces. Incrementing of IP.dst (IPv4 destination address) field
| ... | is applied to the stream.
| ... | *[Ref] Applicable standard specifications:* RFC4303 and RFC2544.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | perfmon_plugin.so
| ... | crypto_native_plugin.so
| ... | crypto_ipsecmb_plugin.so | crypto_openssl_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L3
| ${overhead}= | ${54}
| ${tg_if1_ip4}= | 192.168.10.2
| ${dut1_if1_ip4}= | 192.168.10.1
| ${tun_if1_ip4}= | 100.0.0.1
| ${tun_if2_ip4}= | 200.0.0.2
| ${raddr_ip4}= | 20.0.0.0
| ${laddr_ip4}= | 10.0.0.0
| ${addr_range}= | ${24}
| ${n_tunnels}= | ${1000}
| ${n_added_tunnels}= | ${1}
# Traffic profile:
| ${traffic_profile}= | trex-stl-2n-ethip4-ip4dst${n_tunnels}-udir
| ${traffic_directions}= | ${1}

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs IPSec tunneling AES_256_GCM config.\
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure packet loss during reconfig at NDR load.\
| |
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| |
| | [Arguments] | ${frame_size} | ${phy_cores} | ${rxq}=${None}
| |
| | Set Test Variable | \${frame_size}
| |
| | # These are enums (not strings) so they cannot be in Variables table.
| | ${encr_alg}= | Crypto Alg AES GCM 256
| | ${auth_alg}= | Set Variable | ${NONE}
| | ${ipsec_proto} = | IPsec Proto ESP
| |
| | ${n_total_tunnels} = | Evaluate | ${n_tunnels} + ${n_added_tunnels}
| | Given Set Max Rate And Jumbo
| | And Add worker threads to all DUTs | ${phy_cores} | ${rxq}
| | And Pre-initialize layer driver | ${nic_driver}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Initialize IPSec in 2-node circular topology
| | And VPP IPsec Create Tunnel Interfaces
| | ... | ${nodes} | ${tun_if1_ip4} | ${tun_if2_ip4} | ${DUT1_${int}2}[0]
| | ... | ${TG_pf2}[0] | ${n_tunnels} | ${encr_alg} | ${auth_alg}
| | ... | ${laddr_ip4} | ${raddr_ip4} | ${addr_range}
| | ${unidirectional_throughput} = | Find Throughput Using MLRsearch
| | Start Traffic on Background | ${unidirectional_throughput}
| | And VPP IPsec Create Tunnel Interfaces
| | ... | ${nodes} | ${tun_if1_ip4} | ${tun_if2_ip4} | ${DUT1_${int}2}[0]
| | ... | ${TG_pf2}[0] | ${n_total_tunnels} | ${encr_alg} | ${auth_alg}
| | ... | ${laddr_ip4} | ${raddr_ip4} | ${addr_range} | ${n_tunnels}
| | ${result}= | Stop Running Traffic
| | Display Reconfig Test Message | ${result}

*** Test Cases ***
| 64B-1c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 64B | 1C
| | frame_size=${64} | phy_cores=${1}

| 64B-2c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 64B | 2C
| | frame_size=${64} | phy_cores=${2}

| 64B-4c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 64B | 4C
| | frame_size=${64} | phy_cores=${4}

| 1518B-1c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-ethip4ipsec1000tnlsw-1atnl-ip4base-int-aes256gcm-udir-reconf
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
