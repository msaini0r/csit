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
|
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | ETH | IP4FWD | SCALE | FIB_200K | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | IP4_RND
| ... | ethip4-ip4scale200k-rnd
|
| Suite Setup | Setup suite topology interfaces | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance
|
| Test Template | Local Template
|
| Documentation | **RFC2544: Pkt throughput IPv4 routing test cases**
| ... |
| ... | - **[Top] Network Topologies:** TG-DUT1-TG 2-node circular topology \
| ... | with single links between nodes.
| ... |
| ... | - **[Enc] Packet Encapsulations:** Eth-IPv4 for IPv4 routing.
| ... |
| ... | - **[Cfg] DUT configuration:** DUT1 is configured with IPv4 routing \
| ... | and 2x100k static IPv4 /32 route entries. DUT1 is tested with \
| ... | ${nic_name}.
| ... |
| ... | - **[Ver] TG verification:** TG finds and reports throughput NDR (Non \
| ... | Drop Rate) with zero packet loss tolerance and throughput PDR \
| ... | (Partial Drop Rate) with non-zero packet loss tolerance (LT) \
| ... | expressed in percentage of packets transmitted. NDR and PDR are \
| ... | discovered for different Ethernet L2 frame sizes using MLRsearch \
| ... | library.
| ... | Test packets are generated by TG on links to DUT1. TG traffic profile \
| ... | contains 2 randomized L3 flow-groups (flow-group per direction, 100k \
| ... | flows per flow-group) with all packets containing Ethernet header, \
| ... | IPv4 header with IP protocol=61 and static payload. MAC addresses are \
| ... | matching MAC addresses of the TG node interfaces.
| ... |
| ... | - **[Ref] Applicable standard specifications:** RFC2544.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | perfmon_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L3
| ${overhead}= | ${0}
| ${rts_per_flow}= | ${100000}
# Traffic profile
| ${traffic_profile}= | trex-stl-ethip4-ip4dst-rnd${rts_per_flow}

*** Keywords ***
| Local Template
| |
| | [Documentation]
| | ... | - **[Cfg]** DUT runs IPv4 routing config. \
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | - **[Ver]** Measure NDR and PDR values using MLRsearch algorithm.
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
| | Given Set Max Rate And Jumbo
| | And Add worker threads to all DUTs | ${phy_cores} | ${rxq}
| | And Pre-initialize layer driver | ${nic_driver}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Initialize IPv4 forwarding with scaling in circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 64B-1c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 64B | 1C
| | frame_size=${64} | phy_cores=${1}

| 64B-2c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 64B | 2C
| | frame_size=${64} | phy_cores=${2}

| 64B-4c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 64B | 4C
| | frame_size=${64} | phy_cores=${4}

| 1518B-1c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-ethip4-ip4scale200k-rnd-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
