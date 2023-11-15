# Copyright (c) 2023 Cisco and/or its affiliates.
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

"""Implementation of graphs for iterative data.
"""

import plotly.graph_objects as go
import pandas as pd

from copy import deepcopy

from ..utils.constants import Constants as C
from ..utils.utils import get_color, get_hdrh_latencies


def select_iterative_data(data: pd.DataFrame, itm:dict) -> pd.DataFrame:
    """Select the data for graphs and tables from the provided data frame.

    :param data: Data frame with data for graphs and tables.
    :param itm: Item (in this case job name) which data will be selected from
        the input data frame.
    :type data: pandas.DataFrame
    :type itm: str
    :returns: A data frame with selected data.
    :rtype: pandas.DataFrame
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

    if itm["testtype"] in ("ndr", "pdr"):
        test_type = "ndrpdr"
    elif itm["testtype"] == "mrr":
        test_type = "mrr"
    elif itm["area"] == "hoststack":
        test_type = "hoststack"
    df = data.loc[(
        (data["release"] == itm["rls"]) &
        (data["test_type"] == test_type) &
        (data["passed"] == True)
    )]

    core = str() if itm["dut"] == "trex" else f"{itm['core']}"
    ttype = "ndrpdr" if itm["testtype"] in ("ndr", "pdr") else itm["testtype"]
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
    """Generate the statistical box graph with iterative data (MRR, NDR and PDR,
    for PDR also Latencies).

    :param data: Data frame with iterative data.
    :param sel: Selected tests.
    :param layout: Layout of plot.ly graph.
    :param normalize: If True, the data is normalized to CPU frequency
        Constants.NORM_FREQUENCY.
    :param data: pandas.DataFrame
    :param sel: dict
    :param layout: dict
    :param normalize: bool
    :returns: Tuple of graphs - throughput and latency.
    :rtype: tuple(plotly.graph_objects.Figure, plotly.graph_objects.Figure)
    """

    fig_tput = None
    fig_lat = None

    tput_traces = list()
    y_tput_max = 0
    lat_traces = list()
    y_lat_max = 0
    x_lat = list()
    y_units = set()
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

        if itm["area"] == "hoststack":
            ttype = f"hoststack-{itm['testtype']}"
        else:
            ttype = itm["testtype"]

        y_units.update(itm_data[C.UNIT[ttype]].unique().tolist())

        if itm["testtype"] == "mrr":
            y_data_raw = itm_data[C.VALUE_ITER[ttype]].to_list()[0]
        else:
            y_data_raw = itm_data[C.VALUE_ITER[ttype]].to_list()
        y_data = [(y * norm_factor) for y in y_data_raw]
        if y_data:
            y_tput_max = max(max(y_data), y_tput_max)

        nr_of_samples = len(y_data)

        if itm["testtype"] == "mrr":
            c_data = [
                (
                    f"{itm_data['job'].to_list()[0]}/",
                    f"{itm_data['build'].to_list()[0]}"
                ),
            ] * nr_of_samples
        else:
            c_data = list()
            for _, row in itm_data.iterrows():
                c_data.append(f"{row['job']}/{row['build']}")
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
            marker=dict(color=get_color(idx)),
            customdata=c_data
        )
        tput_traces.append(go.Box(**tput_kwargs))
        show_tput = True

        if ttype == "pdr":
            customdata = list()
            for _, row in itm_data.iterrows():
                customdata.append(
                    get_hdrh_latencies(row, f"{row['job']}/{row['build']}")
                )

            y_lat_row = itm_data[C.VALUE_ITER["latency"]].to_list()
            y_lat = [(y / norm_factor) for y in y_lat_row]
            if y_lat:
                try:
                    y_lat_max = max(max(y_lat), y_lat_max)
                except TypeError:
                    continue
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
                marker=dict(color=get_color(idx)),
                customdata=customdata
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
        pl_tput["yaxis"]["title"] = f"Throughput [{'|'.join(sorted(y_units))}]"
        if y_tput_max:
            pl_tput["yaxis"]["range"] = [0, (int(y_tput_max / 1e6) + 2) * 1e6]
        fig_tput = go.Figure(data=tput_traces, layout=pl_tput)

    if show_latency:
        pl_lat = deepcopy(layout["plot-latency"])
        pl_lat["xaxis"]["tickvals"] = [i for i in range(len(x_lat))]
        pl_lat["xaxis"]["ticktext"] = x_lat
        if y_lat_max:
            pl_lat["yaxis"]["range"] = [0, (int(y_lat_max / 10) + 1) * 10]
        fig_lat = go.Figure(data=lat_traces, layout=pl_lat)

    return fig_tput, fig_lat
