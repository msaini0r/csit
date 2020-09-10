# Copyright (c) 2020 Cisco and/or its affiliates.
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
|
| Variables | resources/test_data/lisp/lisp.py
|
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | DEVICETEST | HW_ENV | DCR_ENV | SCAPY
| ... | NIC_Virtual | IP4FWD | LISP | LISP_IP4o4 | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | ethip4lisp-ip4base
|
| Suite Setup | Setup suite topology interfaces | scapy
| Test Setup | Setup test
| Test Teardown | Tear down test | packet_trace
|
| Test Template | Local Template
|
| Documentation | *ip4-lisp-ip4 encapsulation test cases*
|
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node\
| ... | circular topology with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4-LISP-IPv4-ICMPv4\
| ... | on DUT1-TG, Eth-IPv4-ICMPv4 on TG-DUTn for IPv4 routing\
| ... | over LISPoIPv4 tunnel.
| ... | *[Cfg] DUT configuration:* DUT is configured with IPv4\
| ... | routing and static routes. LISPoIPv4 tunnel is\
| ... | configured between DUT1 and TG2.
| ... | *[Ver] TG verification:* Test ICMPv4 Echo Request packets\
| ... | are sent by TG on if1 link to DUT1; on receive TG verifies\
| ... | packets for correctness and their IPv4 src-addr, dst-addr\
| ... | and MAC addresses.
| ... | *[Ref] Applicable standard specifications:* RFC6830.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | lisp_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | virtual
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${overhead}= | ${54}

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] On DUT1 configure LISP.\
| |
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer. Type: integer
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| |
| | [Arguments] | ${frame_size} | ${phy_cores} | ${rxq}=${None}
| |
| | Set Test Variable | \${frame_size}
| |
| | Given Set Max Rate And Jumbo
| | And Add worker threads to all DUTs | ${phy_cores} | ${rxq}
| | And Pre-initialize layer driver | ${nic_driver}
| | And Apply startup configuration on all VPP DUTs | with_trace=${True}
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Configure topology for IPv4 LISP testing
| | And Configure LISP in 2-node circular topology
| | ... | ${dut1} | ${DUT1_${int}2}[0] | ${NONE}
| | ... | ${duts_locator_set} | ${dut1_ip4_eid}
| | ... | ${dut1_to_tg_ip4_static_adjacency}
| | Then Send packet and verify LISP encap
| | ... | ${tg} | ${tg_if1_ip4} | ${dst_ip4}
| | ... | ${TG_pf1}[0] | ${TG_pf1_mac}[0] | ${DUT1_vf1_mac}[0]
| | ... | ${TG_pf2}[0] | ${DUT1_vf2_mac}[0] | ${TG_pf2_mac}[0]
| | ... | ${src_rloc4} | ${dst_rloc4}

*** Test Cases ***
| 46B-ethip4lisp-ip4base-dev
| | [Tags] | 46B
| | frame_size=${46} | phy_cores=${0}
