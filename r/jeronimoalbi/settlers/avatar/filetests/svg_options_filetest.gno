// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/svg_options_filetest

// SVG applies the size (clamped to 32-2048) and can drop the background.
package svg_options_filetest

import (
	"strings"
	"testing"

	"gno.land/r/jeronimoalbi/settlers/avatar"
	settlers "gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	settlers.UnsafeReset(cross(cur), deployer)
	settlers.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)
	testing.SetRealm(testing.NewUserRealm(alice))
	settlers.Mint(cross(cur), aliceProof)

	println("Size 64:", rootTag(avatar.SVG(alice, 64, false)))
	println("Size 1, below the minimum:", rootTag(avatar.SVG(alice, 1, false)))
	println("Size 5000, above the maximum:", rootTag(avatar.SVG(alice, 5000, false)))
	println("Size 0, scales to the container:", rootTag(avatar.SVG(alice, 0, false)))
	println("Size -5, scales to the container:", rootTag(avatar.SVG(alice, -5, false)))

	withBackground := avatar.SVG(alice, 64, false)
	transparent := avatar.SVG(alice, 64, true)
	start := strings.Index(withBackground, "<rect")
	end := start + strings.Index(withBackground[start:], "/>") + 2
	println("Background element:", withBackground[start:end])
	println("Without the background element, same as transparent:", withBackground[:start]+withBackground[end:] == transparent)
}

// rootTag returns the opening <svg ...> tag, where the width and height attributes live.
func rootTag(svg string) string { return svg[:strings.Index(svg, ">")+1] }

// Output:
// Size 64: <svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 0 32 32" width="64" height="64" shape-rendering="crispEdges">
// Size 1, below the minimum: <svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 0 32 32" width="32" height="32" shape-rendering="crispEdges">
// Size 5000, above the maximum: <svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 0 32 32" width="2048" height="2048" shape-rendering="crispEdges">
// Size 0, scales to the container: <svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 0 32 32" shape-rendering="crispEdges">
// Size -5, scales to the container: <svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 0 32 32" shape-rendering="crispEdges">
// Background element: <rect x="-4" width="32" height="32" fill="#cfe8f3"/>
// Without the background element, same as transparent: true
