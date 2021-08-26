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
| ... | NIC_Intel-X710 |TREX | ETH | IP4FWD | N2N | SCALE | IP4BASE
| ... | TG_DRV_IGB_UIO | UDP | UDP_CPS | HOSTS_1024
| ... | ethip4udp-ip4base-h1024-p63-s64512-cps-tg
|
| Suite Setup | Setup suite topology interfaces with no DUT | performance_tg_nic
| Suite Teardown | Tear down suite | performance
| Test Teardown | Tear down test raw | performance
|
| Test Template | Local Template
|
| Documentation | *CPS on empty UDP transactions with L1 cross connect*
|
| ... | *[Top] Network Topologies:* TG-TG 1-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L1 cross connect patch.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | Test packets are generated by TG on links to TG.\
| ... | TG traffic profile contain L7 flows (${cps} bi-directional UDP flows)\
| ... | with all packets containing Ethernet header, IPv4 header with UDP\
| ... | header and static payload.\
| ... | MAC addresses are matching MAC addresses of the TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${nic_name}= | Intel-X710
| ${nic_pfs}= | 2
| ${osi_layer}= | L7
| ${overhead}= | ${0}
# Scale settings
| ${n_hosts}= | ${1024}
| ${n_ports}= | ${63}
| ${transaction_scale}= | ${${n_hosts} * ${n_ports}}
# Traffic profile
| ${traffic_profile}= | trex-astf-ethip4udp-${n_hosts}h
| ${transaction_type}= | udp_cps
| ${disable_latency}= | ${True}

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] TG runs L1 cross connect config.
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
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
| 64B--ethip4udp-ip4base-h1024-p63-s64512-cps-tg-ndrpdr
| | [Tags] | 64B
| | frame_size=${64}
