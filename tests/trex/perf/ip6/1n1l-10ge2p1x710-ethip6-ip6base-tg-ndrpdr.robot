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
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | 3_NODE_SINGLE_LINK_TOPO
| ... | PERFTEST | HW_ENV | NDRPDR | NIC_Intel-X710 | TREX | ETH | IP6BASE
| ... | N2N | BASE | IP6BASE | TG_DRV_IGB_UIO
| ... | ethip6-ip6base-tg
|
| Suite Setup | Setup suite topology interfaces with no DUT | performance_tg_nic
| Suite Teardown | Tear down suite | performance
| Test Teardown | Tear down test raw | performance
|
| Test Template | Local Template
|
| Documentation | **RFC2544: Pkt throughput for cross connected NICs with IPv6 \
| ... | traffic profile.**
| ... |
| ... | - **[Top] Network Topologies:** TG-TG 1-node circular topology \
| ... | with single link between.
| ... |
| ... | - **[Enc] Packet Encapsulations:** Eth-IPv6 for L1 cross connect patch.
| ... |
| ... | - **[Ver] TG verification:** TG finds and reports throughput NDR (Non \
| ... | Drop Rate) with zero packet loss tolerance and throughput PDR \
| ... | (Partial Drop Rate) with non-zero packet loss tolerance (LT) \
| ... | expressed in percentage of packets transmitted. NDR and PDR are \
| ... | discovered for different Ethernet L2 frame sizes using MLRsearch \
| ... | library.
| ... | Test packets are generated by TG on links to TG. \
| ... | TG traffic profile contains two L3 flow-groups (flow-group per \
| ... | direction, 1M flows per flow-group) with all packets containing \
| ... | Ethernet header, IPv6 header with static payload. \
| ... | MAC addresses are matching MAC addresses of the TG node interfaces.
| ... |
| ... | - **[Ref] Applicable standard specifications:** RFC2544.

*** Variables ***
| ${nic_name}= | Intel-X710
| ${nic_pfs}= | 2
| ${osi_layer}= | L3
| ${overhead}= | ${0}
# Traffic profile:
| ${traffic_profile}= | trex-stl-2n-ethip6-ip6src253

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | - **[Cfg]** TG runs L1 cross connect config.
| | ... | - **[Ver]** Measure NDR and PDR values using MLRsearch algorithm.
| |
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| |
| | [Arguments] | ${frame_size}
| |
| | Set Test Variable | \${frame_size}
| |
| | Given Set Max Rate And Jumbo
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 78B--ethip6-ip6base-tg-ndrpdr
| | [Tags] | 78B
| | frame_size=${78}

| 1518B--ethip6-ip6base-tg-ndrpdr
| | [Tags] | 1518B
| | frame_size=${1518}

| 9000B--ethip6-ip6base-tg-ndrpdr
| | [Tags] | 9000B
| | frame_size=${9000}

| IMIX--ethip6-ip6base-tg-ndrpdr
| | [Tags] | IMIX
| | frame_size=IMIX_v4_1
