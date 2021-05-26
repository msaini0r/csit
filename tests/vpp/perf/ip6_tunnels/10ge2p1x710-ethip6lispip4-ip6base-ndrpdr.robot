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
| Resource | resources/libraries/robot/overlay/lisp.robot
|
| Variables | resources/test_data/lisp/performance/lisp_static_adjacency.py
|
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | IP6FWD | ENCAP | LISP | IP4UNRLAY | IP6OVRLAY
| ... | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | ethip6lispip4-ip6base
|
| Suite Setup | Setup suite topology interfaces | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance
|
| Test Template | Local Template
|
| Documentation | *RFC6830: Pkt throughput Lisp test cases*
|
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.\
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6-LISP-IPv4 on DUT1-DUT2,\
| ... | Eth-IPv6 on TG-DUTn for IPv6 routing over LISPoIPv4 tunnel.\
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv6\
| ... | routing and static routes. LISPoIPv4 tunnel is configured between\
| ... | DUT1 and DUT2. DUT1 and DUT2 tested with ${nic_name}.\
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | *[Ref] Applicable standard specifications:* RFC6830.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | perfmon_plugin.so | lisp_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L3
| ${overhead}= | 48
# Traffic profile:
| ${traffic_profile}= | trex-stl-3n-ethip6-ip6src253

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 LISP remote static mappings and whitelist\
| | ... | filters config.\
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.\
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
| |
| | ... | *Arguments:*
| | ... | - frame_size - Frame size in Bytes as integer or string (IMIX_v4_1).
| | ... |   Type: integer, string
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
| | And Apply startup configuration on all VPP DUTs
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Initialize LISP IPv6 over IPv4 forwarding in 3-node circular topology
| | ... | ${dut1_to_dut2_ip6o4} | ${dut1_to_tg_ip6o4} | ${dut2_to_dut1_ip6o4}
| | ... | ${dut2_to_tg_ip6o4} | ${tg_prefix6o4} | ${dut_prefix6o4}
| | And Configure LISP topology in 3-node circular topology
| | ... | ${dut1} | ${DUT1_${int}2}[0] | ${NONE}
| | ... | ${dut2} | ${DUT2_${int}1}[0] | ${NONE}
| | ... | ${duts_locator_set} | ${dut1_ip6o4_eid} | ${dut2_ip6o4_eid}
| | ... | ${dut1_ip6o4_static_adjacency} | ${dut2_ip6o4_static_adjacency}
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 78B-1c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 78B | 1C
| | frame_size=${78} | phy_cores=${1}

| 78B-2c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 78B | 2C
| | frame_size=${78} | phy_cores=${2}

| 78B-4c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 78B | 4C
| | frame_size=${78} | phy_cores=${4}

| 1518B-1c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-ethip6lispip4-ip6base-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
