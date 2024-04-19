// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using CommunityToolkit.Datasync.Common.Test.Models;
using CommunityToolkit.Datasync.Server;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics.CodeAnalysis;

namespace CommunityToolkit.Datasync.TestService.Controllers;

[ExcludeFromCodeCoverage]
[Route("api/in-memory/kitchensink")]
public class InMemoryKitchenSinkController(IRepository<InMemoryKitchenSink> repository) : TableController<InMemoryKitchenSink>(repository)
{
}