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

"""Module defining TrimmedStat class."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from .discrete_load import DiscreteLoad
from .load_stats import LoadStats
from .target_spec import TargetSpec


@dataclass
class TrimmedStat(LoadStats):
    """Load stats trimmed to a single target.

    Useful mainly for reporting the overall results.
    """

    def __post_init__(self) -> None:
        """Initialize load value and check there is one target to track."""
        super().__post_init__()
        if len(self.target_to_stat) != 1:
            raise ValueError(f"No single target: {self.target_to_stat!r}")

    @staticmethod
    def for_target(stats: LoadStats, target: TargetSpec) -> TrimmedStat:
        """Return new instance with only one target in the mapping.

        :param stats: The load stats instance to trim.
        :param target: The one target which should remain in the mapping.
        :type stats: LoadStats
        :type target: TargetSpec
        :return: Newly created instance.
        :rtype: TrimmedStat
        """
        return TrimmedStat(
            rounding=stats.rounding,
            int_load=stats.int_load,
            target_to_stat={target: stats.target_to_stat[target]},
        )

    @property
    def conditional_throughput(self) -> Optional[DiscreteLoad]:
        """Compute conditional throughput from the load.

        Target stat has dur_rat_sum and good_long.
        The code here adds intended load and handles the case min load is hit.
        If min load is not a lower bound, None is returned.

        :return: Conditional throughput assuming self is a relevant lower bound.
        :rtype: Optional[DiscreteLoad]
        :raises RuntimeError: If target is unclear or load is spurious.
        """
        target = list(self.target_to_stat.keys())[0]
        _, pes = self.estimates(target)
        if not pes:
            if int(self):
                raise RuntimeError(f"Not a lower bound: {self}")
            return None
        # TODO: Verify self is really the clo?
        stat = self.target_to_stat[target]
        loss_ratio = stat.dur_rat_sum / stat.good_long
        ret = self * (1.0 - loss_ratio)
        return ret
