# Copyright (c) 2019 Cisco and/or its affiliates.
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
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | ETH | IP6FWD | SCALE | FIB_20K
| ...
| Suite Setup | Setup suite single link | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test
| Test Teardown | Tear down test | performance
| ...
| Test Template | Local Template
| ...
| Documentation | *RFC2544: Pkt throughput IPv6 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv6\
| ... | routing and 2x10k static IPv6 /64 route entries. DUT1 and DUT2 tested\
| ... | with ${nic_name}.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile\
| ... | contains two L3 flow-groups (flow-group per direction, 10k flows per\
| ... | flow-group) with all packets containing Ethernet header, IPv6 header\
| ... | with IP and static payload. MAC addresses are matching MAC addresses\
| ... | of the TG node interfaces. Incrementing of IP.dst (IPv6 destination\
| ... | address) field is applied to both streams.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so
| ${osi_layer}= | L3
| ${nic_name}= | Intel-X710
| ${overhead}= | ${0}
| ${rts_per_flow}= | ${10000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-3n-ethip6-ip6dst${rts_per_flow}

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config.
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
| | ...
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${frame_size} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | \${frame_size}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | And Set Max Rate And Jumbo And Handle Multi Seg
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv6 forwarding with scaling in circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| tc01-78B-1c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 78B | 1C
| | frame_size=${78} | phy_cores=${1}

| tc02-78B-2c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 78B | 2C
| | frame_size=${78} | phy_cores=${2}

| tc03-78B-4c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 78B | 4C
| | frame_size=${78} | phy_cores=${4}

| tc04-1518B-1c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| tc05-1518B-2c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| tc06-1518B-4c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| tc07-9000B-1c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| tc08-9000B-2c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| tc09-9000B-4c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| tc10-IMIX-1c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-ethip6-ip6scale20k-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
