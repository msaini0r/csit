# Copyright (c) 2017 Cisco and/or its affiliates.
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
| Resource | resources/libraries/robot/performance.robot
| Resource | resources/libraries/robot/tagging.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRCHK
| ... | NIC_Intel-X520-DA2 | L2XCFWD | BASE | DOT1Q
| ...
| Suite Setup | 3-node Performance Suite Setup with DUT's NIC model
| ... | L2 | Intel-X520-DA2
| Suite Teardown | 3-node Performance Suite Teardown
| ...
| Test Setup | Performance test setup
| Test Teardown | Performance ndrchk test teardown
| ...
| Documentation | *Reference NDR throughput L2XC with 802.1q verify test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 cross connect. 802.1q
| ... | tagging is applied on link between DUT1 and DUT2.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 cross-
| ... | connect. DUT1 and DUT2 tested with 2p10GE NIC X520 Niantic by Intel.
| ... | *[Ver] TG verification:* In short performance tests, TG verifies
| ... | DUTs' throughput at ref-NDR (reference Non Drop Rate) with zero packet
| ... | loss tolerance. Ref-NDR value is periodically updated acording to
| ... | formula: ref-NDR = 0.9x NDR, where NDR is found in RFC2544 long
| ... | performance tests for the same DUT configuration. Test packets are
| ... | generated by TG on links to DUTs. TG traffic profile contains two L3
| ... | flow-groups (flow-group per direction, 253 flows per flow-group) with
| ... | all packets containing Ethernet header, IPv4 header with IP protocol=61
| ... | and static payload. MAC addresses are matching MAC addresses of the
| ... | TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${subid}= | 10
| ${tag_rewrite}= | pop-1

*** Test Cases ***
| tc01-64B-1t1c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 64 Byte
| | ... | frames using single trial throughput test at 2x 4.0mpps.
| | [Tags] | 64B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${64}
| | ${rate}= | Set Variable | 4.0mpps
| | Given Add '1' worker threads and rxqueues '1' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Add No Multi Seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc02-1518B-1t1c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 1518 Byte
| | ... | frames using single trial throughput test at 2x 720000pps.
| | [Tags] | 1518B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 720000pps
| | Given Add '1' worker threads and rxqueues '1' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Add No Multi Seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc03-9000B-1t1c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test at 2x 120000pps.
| | [Tags] | 9000B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 120000pps
| | Given Add '1' worker threads and rxqueues '1' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc04-64B-2t2c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 64 Byte
| | ... | frames using single trial throughput test at 2x 8.7mpps.
| | [Tags] | 64B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${64}
| | ${rate}= | Set Variable | 8.7mpps
| | Given Add '2' worker threads and rxqueues '1' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Add No Multi Seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc05-1518B-2t2c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 1518 Byte
| | ... | frames using single trial throughput test at 2x 720000pps.
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 720000pps
| | Given Add '2' worker threads and rxqueues '1' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Add No Multi Seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc06-9000B-2t2c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test at 2x 120000pps.
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 120000pps
| | Given Add '2' worker threads and rxqueues '1' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc07-64B-4t4c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Verify ref-NDR for 64 Byte
| | ... | frames using single trial throughput test at 2x 10.3mpps.
| | [Tags] | 64B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${64}
| | ${rate}= | Set Variable | 10.3mpps
| | Given Add '4' worker threads and rxqueues '2' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Add No Multi Seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc08-1518B-4t4c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Verify ref-NDR for 1518 Byte
| | ... | frames using single trial throughput test at 2x 720000pps.
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 720000pps
| | Given Add '4' worker threads and rxqueues '2' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Add No Multi Seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect

| tc09-9000B-4t4c-dot1q-l2xcbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test at 2x 120000pps.
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 120000pps
| | Given Add '4' worker threads and rxqueues '2' in 3-node single-link topo
| | And Add PCI devices to DUTs from 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | And VPP interfaces in path are up in a 3-node circular topology
| | When VLAN dot1q subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | 3-node-xconnect
