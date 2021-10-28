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
| ... | NIC_Intel-X710 | L2BDMACLRN | ENCAP | VXLAN | L2OVRLAY | IP4UNRLAY
| ... | VHOST | VM | VHOST_1024 | VXLAN | DOT1Q | NF_DENSITY | NF_TESTPMD
| ... | CHAIN | 4R1C | 4VM2T | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd
|
| Suite Setup | Setup suite topology interfaces | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance | vhost
|
| Test Template | Local Template
|
| Documentation | **RFC2544: Packet throughput L2BD test cases with Dot1Q and
| ... | VXLANoIPv4 with ${nf_chains} instances, ${nf_nodes} VMs per instance.**
| ... |
| ... | - **[Top] Network Topologies:** TG-DUT1-TG 2-node circular topology \
| ... | with single links between nodes.
| ... |
| ... | - **[Enc] Packet Encapsulations:** Dot1q-IPv4-UDP-VXLAN-Eth-IPv4 for \
| ... | l2 cross-connect switching of IPv4 Dot1q-IPv4-UDP-VXLAN-Eth-IPv4 is \
| ... | applied on link between DUT1 and TG.
| ... |
| ... | - **[Cfg] DUT configuration:** DUT1 is configured with L2 bridge- \
| ... | domain and MAC learning enabled. Qemu VNFs are connected \
| ... | to VPP via vhost-user interfaces. Guest is running testpmd l2xc \
| ... | interconnecting vhost-user interfaces, rxd/txd=1024. DUT1 is \
| ... | tested with ${nic_name}.
| ... |
| ... | - **[Ver] TG verification:** TG finds and reports throughput NDR (Non \
| ... | Drop Rate) with zero packet loss tolerance and throughput PDR \
| ... | (Partial Drop Rate) with non-zero packet loss tolerance (LT) \
| ... | expressed in percentage of packets transmitted. NDR and PDR are \
| ... | discovered for different Ethernet L2 frame sizes using MLRsearch \
| ... | library.
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile \
| ... | contains two L3 flow-groups (flow-group per direction, 256 flows per \
| ... | flow-group) with all packets containing Ethernet header with .1Q, IPv4 \
| ... | header, UPD header, VXLAN header and static payload. MAC addresses are \
| ... | matching MAC addresses of the TG node interfaces.
| ... |
| ... | - **[Ref] Applicable standard specifications:** RFC2544, RFC7348.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L3
| ${overhead}= | ${54}
| ${nf_dtcr}= | ${1}
| ${nf_dtc}= | ${1}
| ${nf_chains}= | ${4}
| ${nf_nodes}= | ${1}
# Traffic profile:
| ${traffic_profile}=
| ... | trex-stl-dot1qip4vxlan-ip4src${nf_chains}udpsrcrnd

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | - **[Cfg]** DUT runs Dot1Q-IP4-Vxlan L2BD switching config. \
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | - **[Ver]** Measure NDR and PDR values using MLRsearch algorithm.
| |
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of worker threads to be used. Type: integer
| | ... | - rxq - Number of Rx queues to be used. Type: integer
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
| | ... | count=${nf_chains}
| | And Initialize layer dot1q
| | ... | count=${nf_chains} | vlan_per_chain=${False}
| | And Initialize layer ip4vxlan
| | ... | count=${nf_chains}
| | And Initialize L2 bridge domains for multiple chains with Vhost-User
| | ... | nf_chains=${nf_chains} | nf_nodes=${nf_nodes}
| | And Configure chains of NFs connected via vhost-user
| | ... | nf_chains=${nf_chains} | nf_nodes=${nf_nodes} | jumbo=${jumbo}
| | ... | use_tuned_cfs=${False} | auto_scale=${False} | vnf=testpmd_io
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 118B-1c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 118B | 1C
| | frame_size=${118} | phy_cores=${1}

| 118B-2c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 118B | 2C
| | frame_size=${118} | phy_cores=${2}

| 118B-4c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 118B | 4C
| | frame_size=${118} | phy_cores=${4}

| 1518B-1c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-dot1qip4vxlan-l2bd-4ch-8vh-4vm2t-testpmd-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
