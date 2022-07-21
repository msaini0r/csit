# Copyright (c) 2022 Cisco and/or its affiliates.
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

"""
"""

import re
import plotly.graph_objects as go
import pandas as pd

from copy import deepcopy

from ..utils.constants import Constants as C
from ..utils.utils import get_color


def get_short_version(version: str, dut_type: str="vpp") -> str:
    """
    """

    if dut_type in ("trex", "dpdk"):
        return version

    s_version = str()
    groups = re.search(
        pattern=re.compile(r"^(\d{2}).(\d{2})-(rc0|rc1|rc2|release$)"),
        string=version
    )
    if groups:
        try:
            s_version = \
                f"{groups.group(1)}.{groups.group(2)}.{groups.group(3)}".\
                    replace("release", "rls")
        except IndexError:
            pass

    return s_version


def select_iterative_data(data: pd.DataFrame, itm:dict) -> pd.DataFrame:
    """
    """

    phy = itm["phy"].split("-")
    if len(phy) == 4:
        topo, arch, nic, drv = phy
        if drv == "dpdk":
            drv = ""
        else:
            drv += "-"
            drv = drv.replace("_", "-")
    else:
        return None

    core = str() if itm["dut"] == "trex" else f"{itm['core']}"
    ttype = "ndrpdr" if itm["testtype"] in ("ndr", "pdr") else itm["testtype"]
    dut_v100 = "none" if itm["dut"] == "trex" else itm["dut"]
    dut_v101 = itm["dut"]

    df = data.loc[(
        (data["release"] == itm["rls"]) &
        (
            (
                (data["version"] == "1.0.0") &
                (data["dut_type"].str.lower() == dut_v100)
            ) |
            (
                (data["version"] == "1.0.1") &
                (data["dut_type"].str.lower() == dut_v101)
            )
        ) &
        (data["test_type"] == ttype) &
        (data["passed"] == True)
    )]
    regex_test = \
        f"^.*[.|-]{nic}.*{itm['framesize']}-{core}-{drv}{itm['test']}-{ttype}$"
    df = df[
        (df.job.str.endswith(f"{topo}-{arch}")) &
        (df.dut_version.str.contains(itm["dutver"].replace(".r", "-r").\
            replace("rls", "release"))) &
        (df.test_id.str.contains(regex_test, regex=True))
    ]

    return df


def graph_iterative(data: pd.DataFrame, sel:dict, layout: dict,
        normalize: bool) -> tuple:
    """
    """

    fig_tput = None
    fig_lat = None

    tput_traces = list()
    y_tput_max = 0
    lat_traces = list()
    y_lat_max = 0
    x_lat = list()
    show_latency = False
    show_tput = False
    for idx, itm in enumerate(sel):
        itm_data = select_iterative_data(data, itm)
        if itm_data.empty:
            continue
        phy = itm["phy"].split("-")
        topo_arch = f"{phy[0]}-{phy[1]}" if len(phy) == 4 else str()
        norm_factor = (C.NORM_FREQUENCY / C.FREQUENCY[topo_arch]) \
            if normalize else 1.0
        if itm["testtype"] == "mrr":
            y_data_raw = itm_data[C.VALUE_ITER[itm["testtype"]]].to_list()[0]
            y_data = [(y * norm_factor) for y in y_data_raw]
            if len(y_data) > 0:
                y_tput_max = \
                    max(y_data) if max(y_data) > y_tput_max else y_tput_max
        else:
            y_data_raw = itm_data[C.VALUE_ITER[itm["testtype"]]].to_list()
            y_data = [(y * norm_factor) for y in y_data_raw]
            if y_data:
                y_tput_max = \
                    max(y_data) if max(y_data) > y_tput_max else y_tput_max
        nr_of_samples = len(y_data)
        tput_kwargs = dict(
            y=y_data,
            name=(
                f"{idx + 1}. "
                f"({nr_of_samples:02d} "
                f"run{'s' if nr_of_samples > 1 else ''}) "
                f"{itm['id']}"
            ),
            hoverinfo=u"y+name",
            boxpoints="all",
            jitter=0.3,
            marker=dict(color=get_color(idx))
        )
        tput_traces.append(go.Box(**tput_kwargs))
        show_tput = True

        if itm["testtype"] == "pdr":
            y_lat_row = itm_data[C.VALUE_ITER["pdr-lat"]].to_list()
            y_lat = [(y / norm_factor) for y in y_lat_row]
            if y_lat:
                y_lat_max = max(y_lat) if max(y_lat) > y_lat_max else y_lat_max
            nr_of_samples = len(y_lat)
            lat_kwargs = dict(
                y=y_lat,
                name=(
                    f"{idx + 1}. "
                    f"({nr_of_samples:02d} "
                    f"run{u's' if nr_of_samples > 1 else u''}) "
                    f"{itm['id']}"
                ),
                hoverinfo="all",
                boxpoints="all",
                jitter=0.3,
                marker=dict(color=get_color(idx))
            )
            x_lat.append(idx + 1)
            lat_traces.append(go.Box(**lat_kwargs))
            show_latency = True
        else:
            lat_traces.append(go.Box())

    if show_tput:
        pl_tput = deepcopy(layout["plot-throughput"])
        pl_tput["xaxis"]["tickvals"] = [i for i in range(len(sel))]
        pl_tput["xaxis"]["ticktext"] = [str(i + 1) for i in range(len(sel))]
        if y_tput_max:
            pl_tput["yaxis"]["range"] = [0, (int(y_tput_max / 1e6) + 1) * 1e6]
        fig_tput = go.Figure(data=tput_traces, layout=pl_tput)

    if show_latency:
        pl_lat = deepcopy(layout["plot-latency"])
        pl_lat["xaxis"]["tickvals"] = [i for i in range(len(x_lat))]
        pl_lat["xaxis"]["ticktext"] = x_lat
        if y_lat_max:
            pl_lat["yaxis"]["range"] = [0, (int(y_lat_max / 10) + 1) * 10]
        fig_lat = go.Figure(data=lat_traces, layout=pl_lat)

    return fig_tput, fig_lat


def table_comparison(data: pd.DataFrame, sel:dict,
        normalize: bool) -> pd.DataFrame:
    """
    """
    table = pd.DataFrame(
        {
            "Test Case": [
                "64b-2t1c-avf-eth-l2xcbase-eth-2memif-1dcr",
                "64b-2t1c-avf-eth-l2xcbase-eth-2vhostvr1024-1vm-vppl2xc",
                "64b-2t1c-avf-ethip4udp-ip4base-iacl50sl-10kflows",
                "78b-2t1c-avf-ethip6-ip6scale2m-rnd "],
            "2106.0-8": [
                "14.45 +- 0.08",
                "9.63 +- 0.05",
                "9.7 +- 0.02",
                "8.95 +- 0.06"],
            "2110.0-8": [
                "14.45 +- 0.08",
                "9.63 +- 0.05",
                "9.7 +- 0.02",
                "8.95 +- 0.06"],
            "2110.0-9": [
                "14.45 +- 0.08",
                "9.63 +- 0.05",
                "9.7 +- 0.02",
                "8.95 +- 0.06"],
            "2202.0-9": [
                "14.45 +- 0.08",
                "9.63 +- 0.05",
                "9.7 +- 0.02",
                "8.95 +- 0.06"],
            "2110.0-9 vs 2110.0-8": [
                "-0.23 +-  0.62",
                "-1.37 +-   1.3",
                "+0.08 +-   0.2",
                "-2.16 +-  0.83"],
            "2202.0-9 vs 2110.0-9": [
                "+6.95 +-  0.72",
                "+5.35 +-  1.26",
                "+4.48 +-  1.48",
                "+4.09 +-  0.95"]
        }
    )

    return pd.DataFrame()  #table
