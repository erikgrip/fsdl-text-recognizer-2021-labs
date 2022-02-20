from typing import Any, Dict
import argparse

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

NUM_HIDDEN_LAYERS = 1
FC_DIM = 128


class MLP(nn.Module):
    """Simple MLP suitable for recognizing single characters."""

    def __init__(
        self,
        data_config: Dict[str, Any],
        args: argparse.Namespace = None,
    ) -> None:
        super().__init__()
        self.args = vars(args) if args is not None else {}

        input_dim = np.prod(data_config["input_dims"])
        num_classes = len(data_config["mapping"])

        fc_dim = self.args.get("layer_size", FC_DIM)
        num_layers = self.args.get("num_hidden_layers", NUM_HIDDEN_LAYERS)

        self.dropout = nn.Dropout(0.5)

        self.layers = nn.ModuleList([
            nn.Linear(input_dim, fc_dim),  # input layer
            nn.Linear(fc_dim, num_classes)  # output layer
        ])
        for i in range(num_layers):
            self.layers.insert(index=1, module=nn.Linear(fc_dim, fc_dim))

        print(self.layers)


    def forward(self, x):
        x = torch.flatten(x, 1)
        for layer in self.layers:
            # All exept output layer are followed by relu and dropout
            if layer is self.layers[-1]:
                x = layer(x)
            else:
                x = layer(x)
                x = F.relu(x)
                x = self.dropout(x)
        return x

    @staticmethod
    def add_to_argparse(parser):
        parser.add_argument("--num_hidden_layers", type=int, default=NUM_HIDDEN_LAYERS)
        parser.add_argument("--layer_size", type=int, default=FC_DIM)
        return parser
